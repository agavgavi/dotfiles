"""Pydevd extension for Odoo: cleaner debugger views for recordsets, env, fields.

Based on the pydevd-odoo PyPI package by Trinh Anh Ngoc (MIT). Vendored into
debugpy's bundled pydevd to coexist with debugpy, and extended with:

- Single-record dict shows only cached field values + key API anchors,
  not the ~150 inline bound methods and class metadata.
- Environment pretty-print and dict (12 public attrs + _internals group).
- Field pretty-print showing key metadata (type, store, related, compute, ...).
- LazyGettext renders as the translated string.

Each unfiltered object remains reachable via the `_more` entry, which expands
to the default pydevd view.
"""
import sys
from collections import OrderedDict

from _pydevd_bundle.pydevd_extension_api import TypeResolveProvider, StrPresentationProvider
from _pydevd_bundle.pydevd_resolver import defaultResolver


def _safe_subclass(t, base):
    try:
        return issubclass(t, base)
    except (TypeError, AttributeError):
        return False


def _import(path, name=None):
    try:
        mod = __import__(path, fromlist=[name] if name else ['*'])
        return getattr(mod, name) if name else mod
    except (ImportError, AttributeError):
        return None


def _basemodel():
    return (_import('odoo.orm.models', 'BaseModel')
            or _import('odoo.models', 'BaseModel')
            or _import('flectra.models', 'BaseModel'))


def _environment_cls():
    return (_import('odoo.orm.environments', 'Environment')
            or _import('odoo.api', 'Environment'))


def _field_cls():
    return (_import('odoo.orm.fields', 'Field')
            or _import('odoo.fields', 'Field'))


def _lazygettext_cls():
    return _import('odoo.tools.translate', 'LazyGettext')


def _domain_cls():
    return _import('odoo.orm.domains', 'Domain') or _import('odoo.fields', 'Domain')


def _cache_cls():
    return _import('odoo.orm.environments', 'Cache')


# --- "Expand to see default attributes" escape hatch ---

class _DefaultView:
    __slots__ = ('_obj',)
    def __init__(self, obj):
        self._obj = obj
    def __repr__(self):
        return '<all attrs of %s>' % type(self._obj).__name__


class DefaultViewProvider(object):
    def can_provide(self, type_object, type_name):
        return type_object is _DefaultView
    def resolve(self, obj, attr):
        return getattr(obj._obj, attr)
    def get_dictionary(self, obj):
        return defaultResolver.get_dictionary(obj._obj)


# --- Recordset ---

_RECORDSET_ANCHORS = ('id', 'ids', 'env', '_origin', '_context', '_cache',
                       '_ids', '_prefetch_ids', '_name', '_table', '_order',
                       '_rec_name')


class OdooRecordSetProvider(object):
    """Cleaner display for Odoo recordsets.

    - Empty / single record: only cached field values + a small set of API
      anchors (id, ids, env, _origin, _context, ...). Method noise hidden.
    - Multi-record: indexed dict for navigating individual records.
    - get_str: append rec_name suffix for single records.
    """
    def can_provide(self, type_object, type_name):
        bm = _basemodel()
        return bool(bm and _safe_subclass(type_object, bm))

    def resolve(self, obj, attr):
        try:
            idx = int(attr)
        except (ValueError, TypeError):
            return getattr(obj, attr)
        return obj[idx]

    def get_dictionary(self, obj):
        try:
            length = len(obj)
        except Exception:
            return defaultResolver.get_dictionary(obj)

        if length > 1:
            d = OrderedDict()
            for idx, r in enumerate(obj):
                d[str(idx)] = r
            return d

        d = OrderedDict()

        # Cached field values only (never trigger SQL on inspection)
        if length == 1:
            try:
                env = obj.env
                rec_id = obj.id
                obj_type = type(obj)
                for name, field in obj._fields.items():
                    try:
                        cache = field._get_cache(env)
                        if rec_id in cache:
                            d[name] = field.__get__(obj, obj_type)
                    except Exception:
                        pass
            except Exception:
                pass

        for attr in _RECORDSET_ANCHORS:
            if attr in d:
                continue
            try:
                d[attr] = getattr(obj, attr)
            except Exception:
                pass

        d['_more'] = _DefaultView(obj)
        return d

    def get_str(self, val, do_trim=True):
        s = str(val)
        try:
            if len(val) == 1:
                fname = getattr(val, '_rec_name', None)
                if fname:
                    name = getattr(val, fname, None)
                    if name:
                        s += ' ⇨ %s' % name
        except Exception:
            pass
        return s


# --- Environment ---

_ENV_PUBLIC = ('user', 'company', 'companies', 'context', 'cr', 'lang', 'tz',
               'uid', 'su', 'registry', 'transaction', 'cache')

_ENV_INTERNAL = ('_field_access_memo', '_field_cache_memo',
                 '_field_depends_context', '_field_dirty', '_access_cache',
                 '_access_context', '_protected', '_lang', '_recompute_all',
                 '_add_to_access_cache', '_')


class _EnvInternals:
    __slots__ = ('_env',)
    def __init__(self, env):
        self._env = env
    def __repr__(self):
        return '<Environment internals (cache, memos)>'


class EnvInternalsProvider(object):
    def can_provide(self, type_object, type_name):
        return type_object is _EnvInternals
    def resolve(self, obj, attr):
        return getattr(obj._env, attr)
    def get_dictionary(self, obj):
        d = OrderedDict()
        for attr in _ENV_INTERNAL:
            try:
                d[attr] = getattr(obj._env, attr)
            except Exception:
                pass
        return d


class OdooEnvironmentProvider(object):
    def can_provide(self, type_object, type_name):
        env_cls = _environment_cls()
        return bool(env_cls and _safe_subclass(type_object, env_cls))

    def resolve(self, obj, attr):
        if attr == '_internals':
            return _EnvInternals(obj)
        if attr == '_more':
            return _DefaultView(obj)
        return getattr(obj, attr)

    def get_dictionary(self, obj):
        d = OrderedDict()
        for attr in _ENV_PUBLIC:
            try:
                val = getattr(obj, attr)
                if attr == 'cache':
                    val = _CacheView(val)
                d[attr] = val
            except Exception:
                pass
        d['_internals'] = _EnvInternals(obj)
        d['_more'] = _DefaultView(obj)
        return d

    def get_str(self, val, do_trim=True):
        try:
            user = val.user
            user_name = getattr(user, user._rec_name, None) or repr(user)
            company = val.company
            comp_name = getattr(company, company._rec_name, None) or repr(company)
            return ('Environment(user=%s, company=%s, lang=%s, su=%s)'
                    % (user_name, comp_name, val.lang, val.su))
        except Exception:
            return object.__repr__(val)


# --- Cache ---

class _CacheView:
    __slots__ = ('_cache',)
    def __init__(self, cache):
        self._cache = cache
    def __repr__(self):
        try:
            field_data = self._cache.transaction.field_data
            n_fields = len(field_data)
            models = set()
            n_entries = 0
            for field, field_cache in field_data.items():
                models.add(field.model_name)
                n_entries += len(field_cache)
            return '<Cache: %d models, %d fields, %d entries>' % (
                len(models), n_fields, n_entries)
        except Exception:
            return '<Cache>'


class CacheViewProvider(object):
    def can_provide(self, type_object, type_name):
        return type_object is _CacheView
    def resolve(self, obj, attr):
        if attr == '_raw':
            return obj._cache
        # attr is a model name -> return its grouped view
        return self.get_dictionary(obj).get(attr)
    def get_dictionary(self, obj):
        d = OrderedDict()
        try:
            by_model = {}
            for field, field_cache in obj._cache.transaction.field_data.items():
                by_model.setdefault(field.model_name, {})[field.name] = len(field_cache)
            for model_name in sorted(by_model):
                d[model_name] = by_model[model_name]
        except Exception:
            pass
        d['_raw'] = obj._cache
        return d


# --- Field ---

_FIELD_BOOL_TRUE_INTERESTING = ('required', 'readonly', 'translate',
                                 'company_dependent', 'precompute', 'recursive',
                                 'manual', 'unaccent')
_FIELD_BOOL_FALSE_INTERESTING = ('store',)
_FIELD_TRUTHY_INTERESTING = ('related', 'compute', 'inverse', 'search', 'default',
                              'comodel_name', 'selection', 'digits', 'index',
                              'aggregator', 'group_expand', 'help', 'string',
                              'depends', 'depends_context', 'inverse_name',
                              'relation', 'domain', 'context', 'ondelete')


def _field_render_callable(v):
    """Render compute/inverse/search values: names only, not <bound method ...>."""
    if v is None or v is False:
        return None
    if isinstance(v, str):
        return repr(v)
    name = getattr(v, '__name__', None)
    return repr(name) if name else None


class OdooFieldProvider(object):
    def can_provide(self, type_object, type_name):
        f = _field_cls()
        return bool(f and _safe_subclass(type_object, f))

    def resolve(self, obj, attr):
        if attr == '_more':
            return _DefaultView(obj)
        return getattr(obj, attr)

    def get_dictionary(self, obj):
        d = OrderedDict()
        for key in ('name', 'model_name', 'type'):
            try:
                v = getattr(obj, key, None)
                if v is not None:
                    d[key] = v
            except Exception:
                pass

        for attr in _FIELD_BOOL_TRUE_INTERESTING:
            try:
                if getattr(obj, attr, False) is True:
                    d[attr] = True
            except Exception:
                pass

        for attr in _FIELD_BOOL_FALSE_INTERESTING:
            try:
                if getattr(obj, attr, True) is False:
                    d[attr] = False
            except Exception:
                pass

        # When related is set, compute/inverse are auto-bound to internal
        # _compute_related/_inverse_related; skip them as noise.
        is_related = bool(getattr(obj, 'related', None))
        for attr in _FIELD_TRUTHY_INTERESTING:
            if is_related and attr in ('compute', 'inverse'):
                continue
            try:
                v = getattr(obj, attr, None)
                if v:
                    d[attr] = v
            except Exception:
                pass

        d['_more'] = _DefaultView(obj)
        return d

    def get_str(self, val, do_trim=True):
        try:
            type_name = type(val).__name__
            parts = []
            comodel = getattr(val, 'comodel_name', None)
            if comodel:
                parts.append(repr(comodel))
            name = getattr(val, 'name', None)
            if name:
                parts.append('name=%r' % name)
            sel = getattr(val, 'selection', None)
            if isinstance(sel, list) and sel:
                keys = [item[0] for item in sel[:4] if isinstance(item, tuple) and item]
                suffix = ', ...' if len(sel) > 4 else ''
                parts.append('selection=[%s%s]' % (
                    ', '.join(repr(k) for k in keys), suffix))
            elif callable(sel):
                fn_name = getattr(sel, '__name__', None)
                if fn_name:
                    parts.append('selection=%r' % fn_name)
            digits = getattr(val, 'digits', None)
            if digits:
                parts.append('digits=%r' % (digits,))
            related = getattr(val, 'related', None)
            if related:
                parts.append('related=%r' % related)
            else:
                for attr in ('compute', 'inverse', 'search'):
                    rendered = _field_render_callable(getattr(val, attr, None))
                    if rendered:
                        parts.append('%s=%s' % (attr, rendered))
            default = getattr(val, 'default', None)
            if default is not None:
                if callable(default):
                    fn_name = getattr(default, '__name__', None)
                    if fn_name and fn_name != '<lambda>':
                        parts.append('default=%s' % fn_name)
                    elif fn_name == '<lambda>':
                        parts.append('default=<lambda>')
                else:
                    parts.append('default=%r' % (default,))
            if getattr(val, 'store', True) is False:
                parts.append('store=False')
            if getattr(val, 'required', False) is True:
                parts.append('required=True')
            if getattr(val, 'translate', False):
                parts.append('translate=True')
            return '%s(%s)' % (type_name, ', '.join(parts)) if parts else type_name
        except Exception:
            return str(val)


# --- Domain (AST representation) ---

class OdooDomainProvider(object):
    """Show Domain children as the iterated list-of-tuples form. Inline str
    relies on Domain.__repr__ which already returns the old-style list form."""
    def can_provide(self, type_object, type_name):
        d = _domain_cls()
        return bool(d and _safe_subclass(type_object, d))

    def resolve(self, obj, attr):
        if attr == '_more':
            return _DefaultView(obj)
        try:
            idx = int(attr)
            return list(obj)[idx]
        except (ValueError, TypeError):
            pass
        return getattr(obj, attr)

    def get_dictionary(self, obj):
        d = OrderedDict()
        try:
            for i, item in enumerate(obj):
                d[str(i)] = item
        except Exception:
            pass
        d['_more'] = _DefaultView(obj)
        return d


# --- mappingproxy of Field instances (typically `obj._fields`) ---

class OdooFieldsMapProvider(object):
    """Render mappingproxy as a clean dict when its values are Field instances."""
    def can_provide(self, type_object, type_name):
        return type_name == 'mappingproxy'

    def resolve(self, obj, attr):
        try:
            return obj[attr]
        except (KeyError, TypeError):
            return getattr(obj, attr)

    def get_dictionary(self, obj):
        field_cls = _field_cls()
        try:
            items = list(obj.items())
        except Exception:
            return defaultResolver.get_dictionary(obj)
        if items and field_cls and all(isinstance(v, field_cls) for _, v in items):
            d = OrderedDict()
            for k, v in items:
                d[k] = v
            return d
        return defaultResolver.get_dictionary(obj)


# --- LazyGettext (Odoo's _lt(...) lazy translations) ---

class OdooLazyGettextProvider(object):
    def can_provide(self, type_object, type_name):
        lg = _lazygettext_cls()
        return bool(lg and _safe_subclass(type_object, lg))

    def get_str(self, val, do_trim=True):
        try:
            return val._translate()
        except Exception:
            try:
                return repr(val)
            except Exception:
                return object.__repr__(val)


# --- Registration ---

if not sys.platform.startswith('java'):
    for cls in (OdooRecordSetProvider, OdooEnvironmentProvider,
                OdooFieldProvider, OdooDomainProvider, OdooFieldsMapProvider,
                EnvInternalsProvider, DefaultViewProvider, CacheViewProvider):
        TypeResolveProvider.register(cls)
    for cls in (OdooRecordSetProvider, OdooEnvironmentProvider,
                OdooFieldProvider, OdooLazyGettextProvider):
        StrPresentationProvider.register(cls)
