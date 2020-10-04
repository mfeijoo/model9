!function(n){var s="object"==typeof self&&self.self===self&&self||"object"==typeof global&&global.global===global&&global;if("function"==typeof define&&define.amd)define(["underscore","jquery","exports"],function(t,e,i){s.Backbone=n(s,i,t,e)});else if("undefined"!=typeof exports){var t,e=require("underscore");try{t=require("jquery")}catch(t){}n(s,exports,e,t)}else s.Backbone=n(s,{},s._,s.jQuery||s.Zepto||s.ender||s.$)}(function(t,h,x,e){var i=t.Backbone,r=Array.prototype.slice;h.VERSION="1.3.3",h.$=e,h.noConflict=function(){return t.Backbone=i,this},h.emulateHTTP=!1,h.emulateJSON=!1;var n=function(i,t,n){x.each(t,function(t,e){x[e]&&(i.prototype[e]=function(t,n,s){switch(t){case 1:return function(){return x[n](this[s])};case 2:return function(t){return x[n](this[s],t)};case 3:return function(t,e){return x[n](this[s],a(t,this),e)};case 4:return function(t,e,i){return x[n](this[s],a(t,this),e,i)};default:return function(){var t=r.call(arguments);return t.unshift(this[s]),x[n].apply(x,t)}}}(t,e,n))})},a=function(e,t){return x.isFunction(e)?e:x.isObject(e)&&!t._isModel(e)?s(e):x.isString(e)?function(t){return t.get(e)}:e},s=function(t){var e=x.matches(t);return function(t){return e(t.attributes)}},o=h.Events={},u=/\s+/,c=function(t,e,i,n,s){var r,a=0;if(i&&"object"==typeof i){void 0!==n&&"context"in s&&void 0===s.context&&(s.context=n);for(r=x.keys(i);a<r.length;a++)e=c(t,e,r[a],i[r[a]],s)}else if(i&&u.test(i))for(r=i.split(u);a<r.length;a++)e=t(e,r[a],n,s);else e=t(e,i,n,s);return e};o.on=function(t,e,i){return l(this,t,e,i)};var l=function(t,e,i,n,s){(t._events=c(d,t._events||{},e,i,{context:n,ctx:t,listening:s}),s)&&((t._listeners||(t._listeners={}))[s.id]=s);return t};o.listenTo=function(t,e,i){if(!t)return this;var n=t._listenId||(t._listenId=x.uniqueId("l")),s=this._listeningTo||(this._listeningTo={}),r=s[n];if(!r){var a=this._listenId||(this._listenId=x.uniqueId("l"));r=s[n]={obj:t,objId:n,id:a,listeningTo:s,count:0}}return l(t,e,i,this,r),this};var d=function(t,e,i,n){if(i){var s=t[e]||(t[e]=[]),r=n.context,a=n.ctx,o=n.listening;o&&o.count++,s.push({callback:i,context:r,ctx:r||a,listening:o})}return t};o.off=function(t,e,i){return this._events&&(this._events=c(f,this._events,t,e,{context:i,listeners:this._listeners})),this},o.stopListening=function(t,e,i){var n=this._listeningTo;if(!n)return this;for(var s=t?[t._listenId]:x.keys(n),r=0;r<s.length;r++){var a=n[s[r]];if(!a)break;a.obj.off(e,i,this)}return this};var f=function(t,e,i,n){if(t){var s,r=0,a=n.context,o=n.listeners;if(e||i||a){for(var h=e?[e]:x.keys(t);r<h.length;r++){var u=t[e=h[r]];if(!u)break;for(var c=[],l=0;l<u.length;l++){var d=u[l];i&&i!==d.callback&&i!==d.callback._callback||a&&a!==d.context?c.push(d):(s=d.listening)&&0==--s.count&&(delete o[s.id],delete s.listeningTo[s.objId])}c.length?t[e]=c:delete t[e]}return t}for(var f=x.keys(o);r<f.length;r++)delete o[(s=o[f[r]]).id],delete s.listeningTo[s.objId]}};o.once=function(t,e,i){var n=c(g,{},t,e,x.bind(this.off,this));return"string"==typeof t&&null==i&&(e=void 0),this.on(n,e,i)},o.listenToOnce=function(t,e,i){var n=c(g,{},e,i,x.bind(this.stopListening,this,t));return this.listenTo(t,n)};var g=function(t,e,i,n){if(i){var s=t[e]=x.once(function(){n(e,s),i.apply(this,arguments)});s._callback=i}return t};o.trigger=function(t){if(!this._events)return this;for(var e=Math.max(0,arguments.length-1),i=Array(e),n=0;n<e;n++)i[n]=arguments[n+1];return c(p,this._events,t,void 0,i),this};var p=function(t,e,i,n){if(t){var s=t[e],r=t.all;s&&r&&(r=r.slice()),s&&v(s,n),r&&v(r,[e].concat(n))}return t},v=function(t,e){var i,n=-1,s=t.length,r=e[0],a=e[1],o=e[2];switch(e.length){case 0:for(;++n<s;)(i=t[n]).callback.call(i.ctx);return;case 1:for(;++n<s;)(i=t[n]).callback.call(i.ctx,r);return;case 2:for(;++n<s;)(i=t[n]).callback.call(i.ctx,r,a);return;case 3:for(;++n<s;)(i=t[n]).callback.call(i.ctx,r,a,o);return;default:for(;++n<s;)(i=t[n]).callback.apply(i.ctx,e);return}};o.bind=o.on,o.unbind=o.off,x.extend(h,o);var m=h.Model=function(t,e){var i=t||{};e||(e={}),this.cid=x.uniqueId(this.cidPrefix),this.attributes={},e.collection&&(this.collection=e.collection),e.parse&&(i=this.parse(i,e)||{});var n=x.result(this,"defaults");i=x.defaults(x.extend({},n,i),n),this.set(i,e),this.changed={},this.initialize.apply(this,arguments)};x.extend(m.prototype,o,{changed:null,validationError:null,idAttribute:"id",cidPrefix:"c",initialize:function(){},toJSON:function(t){return x.clone(this.attributes)},sync:function(){return h.sync.apply(this,arguments)},get:function(t){return this.attributes[t]},escape:function(t){return x.escape(this.get(t))},has:function(t){return null!=this.get(t)},matches:function(t){return!!x.iteratee(t,this)(this.attributes)},set:function(t,e,i){if(null==t)return this;var n;if("object"==typeof t?(n=t,i=e):(n={})[t]=e,i||(i={}),!this._validate(n,i))return!1;var s=i.unset,r=i.silent,a=[],o=this._changing;this._changing=!0,o||(this._previousAttributes=x.clone(this.attributes),this.changed={});var h=this.attributes,u=this.changed,c=this._previousAttributes;for(var l in n)e=n[l],x.isEqual(h[l],e)||a.push(l),x.isEqual(c[l],e)?delete u[l]:u[l]=e,s?delete h[l]:h[l]=e;if(this.idAttribute in n&&(this.id=this.get(this.idAttribute)),!r){a.length&&(this._pending=i);for(var d=0;d<a.length;d++)this.trigger("change:"+a[d],this,h[a[d]],i)}if(o)return this;if(!r)for(;this._pending;)i=this._pending,this._pending=!1,this.trigger("change",this,i);return this._pending=!1,this._changing=!1,this},unset:function(t,e){return this.set(t,void 0,x.extend({},e,{unset:!0}))},clear:function(t){var e={};for(var i in this.attributes)e[i]=void 0;return this.set(e,x.extend({},t,{unset:!0}))},hasChanged:function(t){return null==t?!x.isEmpty(this.changed):x.has(this.changed,t)},changedAttributes:function(t){if(!t)return!!this.hasChanged()&&x.clone(this.changed);var e=this._changing?this._previousAttributes:this.attributes,i={};for(var n in t){var s=t[n];x.isEqual(e[n],s)||(i[n]=s)}return!!x.size(i)&&i},previous:function(t){return null!=t&&this._previousAttributes?this._previousAttributes[t]:null},previousAttributes:function(){return x.clone(this._previousAttributes)},fetch:function(i){i=x.extend({parse:!0},i);var n=this,s=i.success;return i.success=function(t){var e=i.parse?n.parse(t,i):t;if(!n.set(e,i))return!1;s&&s.call(i.context,n,t,i),n.trigger("sync",n,t,i)},O(this,i),this.sync("read",this,i)},save:function(t,e,i){var n;null==t||"object"==typeof t?(n=t,i=e):(n={})[t]=e;var s=(i=x.extend({validate:!0,parse:!0},i)).wait;if(n&&!s){if(!this.set(n,i))return!1}else if(!this._validate(n,i))return!1;var r=this,a=i.success,o=this.attributes;i.success=function(t){r.attributes=o;var e=i.parse?r.parse(t,i):t;if(s&&(e=x.extend({},n,e)),e&&!r.set(e,i))return!1;a&&a.call(i.context,r,t,i),r.trigger("sync",r,t,i)},O(this,i),n&&s&&(this.attributes=x.extend({},o,n));var h=this.isNew()?"create":i.patch?"patch":"update";"patch"!==h||i.attrs||(i.attrs=n);var u=this.sync(h,this,i);return this.attributes=o,u},destroy:function(e){e=e?x.clone(e):{};var i=this,n=e.success,s=e.wait,r=function(){i.stopListening(),i.trigger("destroy",i,i.collection,e)},t=!(e.success=function(t){s&&r(),n&&n.call(e.context,i,t,e),i.isNew()||i.trigger("sync",i,t,e)});return this.isNew()?x.defer(e.success):(O(this,e),t=this.sync("delete",this,e)),s||r(),t},url:function(){var t=x.result(this,"urlRoot")||x.result(this.collection,"url")||M();if(this.isNew())return t;var e=this.get(this.idAttribute);return t.replace(/[^\/]$/,"$&/")+encodeURIComponent(e)},parse:function(t,e){return t},clone:function(){return new this.constructor(this.attributes)},isNew:function(){return!this.has(this.idAttribute)},isValid:function(t){return this._validate({},x.extend({},t,{validate:!0}))},_validate:function(t,e){if(!e.validate||!this.validate)return!0;t=x.extend({},this.attributes,t);var i=this.validationError=this.validate(t,e)||null;return!i||(this.trigger("invalid",this,i,x.extend(e,{validationError:i})),!1)}});n(m,{keys:1,values:1,pairs:1,invert:1,pick:0,omit:0,chain:1,isEmpty:1},"attributes");var _=h.Collection=function(t,e){e||(e={}),e.model&&(this.model=e.model),void 0!==e.comparator&&(this.comparator=e.comparator),this._reset(),this.initialize.apply(this,arguments),t&&this.reset(t,x.extend({silent:!0},e))},w={add:!0,remove:!0,merge:!0},y={add:!0,remove:!1},E=function(t,e,i){i=Math.min(Math.max(i,0),t.length);var n,s=Array(t.length-i),r=e.length;for(n=0;n<s.length;n++)s[n]=t[n+i];for(n=0;n<r;n++)t[n+i]=e[n];for(n=0;n<s.length;n++)t[n+r+i]=s[n]};x.extend(_.prototype,o,{model:m,initialize:function(){},toJSON:function(e){return this.map(function(t){return t.toJSON(e)})},sync:function(){return h.sync.apply(this,arguments)},add:function(t,e){return this.set(t,x.extend({merge:!1},e,y))},remove:function(t,e){e=x.extend({},e);var i=!x.isArray(t);t=i?[t]:t.slice();var n=this._removeModels(t,e);return!e.silent&&n.length&&(e.changes={added:[],merged:[],removed:n},this.trigger("update",this,e)),i?n[0]:n},set:function(t,e){if(null!=t){(e=x.extend({},w,e)).parse&&!this._isModel(t)&&(t=this.parse(t,e)||[]);var i=!x.isArray(t);t=i?[t]:t.slice();var n=e.at;null!=n&&(n=+n),n>this.length&&(n=this.length),n<0&&(n+=this.length+1);var s,r,a=[],o=[],h=[],u=[],c={},l=e.add,d=e.merge,f=e.remove,g=!1,p=this.comparator&&null==n&&!1!==e.sort,v=x.isString(this.comparator)?this.comparator:null;for(r=0;r<t.length;r++){s=t[r];var m=this.get(s);if(m){if(d&&s!==m){var _=this._isModel(s)?s.attributes:s;e.parse&&(_=m.parse(_,e)),m.set(_,e),h.push(m),p&&!g&&(g=m.hasChanged(v))}c[m.cid]||(c[m.cid]=!0,a.push(m)),t[r]=m}else l&&(s=t[r]=this._prepareModel(s,e))&&(o.push(s),this._addReference(s,e),c[s.cid]=!0,a.push(s))}if(f){for(r=0;r<this.length;r++)c[(s=this.models[r]).cid]||u.push(s);u.length&&this._removeModels(u,e)}var y=!1,b=!p&&l&&f;if(a.length&&b?(y=this.length!==a.length||x.some(this.models,function(t,e){return t!==a[e]}),this.models.length=0,E(this.models,a,0),this.length=this.models.length):o.length&&(p&&(g=!0),E(this.models,o,null==n?this.length:n),this.length=this.models.length),g&&this.sort({silent:!0}),!e.silent){for(r=0;r<o.length;r++)null!=n&&(e.index=n+r),(s=o[r]).trigger("add",s,this,e);(g||y)&&this.trigger("sort",this,e),(o.length||u.length||h.length)&&(e.changes={added:o,removed:u,merged:h},this.trigger("update",this,e))}return i?t[0]:t}},reset:function(t,e){e=e?x.clone(e):{};for(var i=0;i<this.models.length;i++)this._removeReference(this.models[i],e);return e.previousModels=this.models,this._reset(),t=this.add(t,x.extend({silent:!0},e)),e.silent||this.trigger("reset",this,e),t},push:function(t,e){return this.add(t,x.extend({at:this.length},e))},pop:function(t){var e=this.at(this.length-1);return this.remove(e,t)},unshift:function(t,e){return this.add(t,x.extend({at:0},e))},shift:function(t){var e=this.at(0);return this.remove(e,t)},slice:function(){return r.apply(this.models,arguments)},get:function(t){if(null!=t)return this._byId[t]||this._byId[this.modelId(t.attributes||t)]||t.cid&&this._byId[t.cid]},has:function(t){return null!=this.get(t)},at:function(t){return t<0&&(t+=this.length),this.models[t]},where:function(t,e){return this[e?"find":"filter"](t)},findWhere:function(t){return this.where(t,!0)},sort:function(t){var e=this.comparator;if(!e)throw new Error("Cannot sort a set without a comparator");t||(t={});var i=e.length;return x.isFunction(e)&&(e=x.bind(e,this)),1===i||x.isString(e)?this.models=this.sortBy(e):this.models.sort(e),t.silent||this.trigger("sort",this,t),this},pluck:function(t){return this.map(t+"")},fetch:function(i){var n=(i=x.extend({parse:!0},i)).success,s=this;return i.success=function(t){var e=i.reset?"reset":"set";s[e](t,i),n&&n.call(i.context,s,t,i),s.trigger("sync",s,t,i)},O(this,i),this.sync("read",this,i)},create:function(t,e){var n=(e=e?x.clone(e):{}).wait;if(!(t=this._prepareModel(t,e)))return!1;n||this.add(t,e);var s=this,r=e.success;return e.success=function(t,e,i){n&&s.add(t,i),r&&r.call(i.context,t,e,i)},t.save(null,e),t},parse:function(t,e){return t},clone:function(){return new this.constructor(this.models,{model:this.model,comparator:this.comparator})},modelId:function(t){return t[this.model.prototype.idAttribute||"id"]},_reset:function(){this.length=0,this.models=[],this._byId={}},_prepareModel:function(t,e){if(this._isModel(t))return t.collection||(t.collection=this),t;var i=new(((e=e?x.clone(e):{}).collection=this).model)(t,e);return i.validationError?(this.trigger("invalid",this,i.validationError,e),!1):i},_removeModels:function(t,e){for(var i=[],n=0;n<t.length;n++){var s=this.get(t[n]);if(s){var r=this.indexOf(s);this.models.splice(r,1),this.length--,delete this._byId[s.cid];var a=this.modelId(s.attributes);null!=a&&delete this._byId[a],e.silent||(e.index=r,s.trigger("remove",s,this,e)),i.push(s),this._removeReference(s,e)}}return i},_isModel:function(t){return t instanceof m},_addReference:function(t,e){this._byId[t.cid]=t;var i=this.modelId(t.attributes);null!=i&&(this._byId[i]=t),t.on("all",this._onModelEvent,this)},_removeReference:function(t,e){delete this._byId[t.cid];var i=this.modelId(t.attributes);null!=i&&delete this._byId[i],this===t.collection&&delete t.collection,t.off("all",this._onModelEvent,this)},_onModelEvent:function(t,e,i,n){if(e){if(("add"===t||"remove"===t)&&i!==this)return;if("destroy"===t&&this.remove(e,n),"change"===t){var s=this.modelId(e.previousAttributes()),r=this.modelId(e.attributes);s!==r&&(null!=s&&delete this._byId[s],null!=r&&(this._byId[r]=e))}}this.trigger.apply(this,arguments)}});n(_,{forEach:3,each:3,map:3,collect:3,reduce:0,foldl:0,inject:0,reduceRight:0,foldr:0,find:3,detect:3,filter:3,select:3,reject:3,every:3,all:3,some:3,any:3,include:3,includes:3,contains:3,invoke:0,max:3,min:3,toArray:1,size:1,first:3,head:3,take:3,initial:3,rest:3,tail:3,drop:3,last:3,without:0,difference:0,indexOf:3,shuffle:1,lastIndexOf:3,isEmpty:1,chain:1,sample:3,partition:3,groupBy:3,countBy:3,sortBy:3,indexBy:3,findIndex:3,findLastIndex:3},"models");var b=h.View=function(t){this.cid=x.uniqueId("view"),x.extend(this,x.pick(t,S)),this._ensureElement(),this.initialize.apply(this,arguments)},I=/^(\S+)\s*(.*)$/,S=["model","collection","el","id","attributes","className","tagName","events"];x.extend(b.prototype,o,{tagName:"div",$:function(t){return this.$el.find(t)},initialize:function(){},render:function(){return this},remove:function(){return this._removeElement(),this.stopListening(),this},_removeElement:function(){this.$el.remove()},setElement:function(t){return this.undelegateEvents(),this._setElement(t),this.delegateEvents(),this},_setElement:function(t){this.$el=t instanceof h.$?t:h.$(t),this.el=this.$el[0]},delegateEvents:function(t){if(t||(t=x.result(this,"events")),!t)return this;for(var e in this.undelegateEvents(),t){var i=t[e];if(x.isFunction(i)||(i=this[i]),i){var n=e.match(I);this.delegate(n[1],n[2],x.bind(i,this))}}return this},delegate:function(t,e,i){return this.$el.on(t+".delegateEvents"+this.cid,e,i),this},undelegateEvents:function(){return this.$el&&this.$el.off(".delegateEvents"+this.cid),this},undelegate:function(t,e,i){return this.$el.off(t+".delegateEvents"+this.cid,e,i),this},_createElement:function(t){return document.createElement(t)},_ensureElement:function(){if(this.el)this.setElement(x.result(this,"el"));else{var t=x.extend({},x.result(this,"attributes"));this.id&&(t.id=x.result(this,"id")),this.className&&(t.class=x.result(this,"className")),this.setElement(this._createElement(x.result(this,"tagName"))),this._setAttributes(t)}},_setAttributes:function(t){this.$el.attr(t)}}),h.sync=function(t,e,n){var i=k[t];x.defaults(n||(n={}),{emulateHTTP:h.emulateHTTP,emulateJSON:h.emulateJSON});var s={type:i,dataType:"json"};if(n.url||(s.url=x.result(e,"url")||M()),null!=n.data||!e||"create"!==t&&"update"!==t&&"patch"!==t||(s.contentType="application/json",s.data=JSON.stringify(n.attrs||e.toJSON(n))),n.emulateJSON&&(s.contentType="application/x-www-form-urlencoded",s.data=s.data?{model:s.data}:{}),n.emulateHTTP&&("PUT"===i||"DELETE"===i||"PATCH"===i)){s.type="POST",n.emulateJSON&&(s.data._method=i);var r=n.beforeSend;n.beforeSend=function(t){if(t.setRequestHeader("X-HTTP-Method-Override",i),r)return r.apply(this,arguments)}}"GET"===s.type||n.emulateJSON||(s.processData=!1);var a=n.error;n.error=function(t,e,i){n.textStatus=e,n.errorThrown=i,a&&a.call(n.context,t,e,i)};var o=n.xhr=h.ajax(x.extend(s,n));return e.trigger("request",e,o,n),o};var k={create:"POST",update:"PUT",patch:"PATCH",delete:"DELETE",read:"GET"};h.ajax=function(){return h.$.ajax.apply(h.$,arguments)};var T=h.Router=function(t){t||(t={}),t.routes&&(this.routes=t.routes),this._bindRoutes(),this.initialize.apply(this,arguments)},P=/\((.*?)\)/g,H=/(\(\?)?:\w+/g,$=/\*\w+/g,A=/[\-{}\[\]+?.,\\\^$|#\s]/g;x.extend(T.prototype,o,{initialize:function(){},route:function(i,n,s){x.isRegExp(i)||(i=this._routeToRegExp(i)),x.isFunction(n)&&(s=n,n=""),s||(s=this[n]);var r=this;return h.history.route(i,function(t){var e=r._extractParameters(i,t);!1!==r.execute(s,e,n)&&(r.trigger.apply(r,["route:"+n].concat(e)),r.trigger("route",n,e),h.history.trigger("route",r,n,e))}),this},execute:function(t,e,i){t&&t.apply(this,e)},navigate:function(t,e){return h.history.navigate(t,e),this},_bindRoutes:function(){if(this.routes){this.routes=x.result(this,"routes");for(var t,e=x.keys(this.routes);null!=(t=e.pop());)this.route(t,this.routes[t])}},_routeToRegExp:function(t){return t=t.replace(A,"\\$&").replace(P,"(?:$1)?").replace(H,function(t,e){return e?t:"([^/?]+)"}).replace($,"([^?]*?)"),new RegExp("^"+t+"(?:\\?([\\s\\S]*))?$")},_extractParameters:function(t,e){var i=t.exec(e).slice(1);return x.map(i,function(t,e){return e===i.length-1?t||null:t?decodeURIComponent(t):null})}});var C=h.History=function(){this.handlers=[],this.checkUrl=x.bind(this.checkUrl,this),"undefined"!=typeof window&&(this.location=window.location,this.history=window.history)},R=/^[#\/]|\s+$/g,j=/^\/+|\/+$/g,N=/#.*$/;C.started=!1,x.extend(C.prototype,o,{interval:50,atRoot:function(){return this.location.pathname.replace(/[^\/]$/,"$&/")===this.root&&!this.getSearch()},matchRoot:function(){return this.decodeFragment(this.location.pathname).slice(0,this.root.length-1)+"/"===this.root},decodeFragment:function(t){return decodeURI(t.replace(/%25/g,"%2525"))},getSearch:function(){var t=this.location.href.replace(/#.*/,"").match(/\?.+/);return t?t[0]:""},getHash:function(t){var e=(t||this).location.href.match(/#(.*)$/);return e?e[1]:""},getPath:function(){var t=this.decodeFragment(this.location.pathname+this.getSearch()).slice(this.root.length-1);return"/"===t.charAt(0)?t.slice(1):t},getFragment:function(t){return null==t&&(t=this._usePushState||!this._wantsHashChange?this.getPath():this.getHash()),t.replace(R,"")},start:function(t){if(C.started)throw new Error("Backbone.history has already been started");if(C.started=!0,this.options=x.extend({root:"/"},this.options,t),this.root=this.options.root,this._wantsHashChange=!1!==this.options.hashChange,this._hasHashChange="onhashchange"in window&&(void 0===document.documentMode||7<document.documentMode),this._useHashChange=this._wantsHashChange&&this._hasHashChange,this._wantsPushState=!!this.options.pushState,this._hasPushState=!(!this.history||!this.history.pushState),this._usePushState=this._wantsPushState&&this._hasPushState,this.fragment=this.getFragment(),this.root=("/"+this.root+"/").replace(j,"/"),this._wantsHashChange&&this._wantsPushState){if(!this._hasPushState&&!this.atRoot()){var e=this.root.slice(0,-1)||"/";return this.location.replace(e+"#"+this.getPath()),!0}this._hasPushState&&this.atRoot()&&this.navigate(this.getHash(),{replace:!0})}if(!this._hasHashChange&&this._wantsHashChange&&!this._usePushState){this.iframe=document.createElement("iframe"),this.iframe.src="javascript:0",this.iframe.style.display="none",this.iframe.tabIndex=-1;var i=document.body,n=i.insertBefore(this.iframe,i.firstChild).contentWindow;n.document.open(),n.document.close(),n.location.hash="#"+this.fragment}var s=window.addEventListener||function(t,e){return attachEvent("on"+t,e)};if(this._usePushState?s("popstate",this.checkUrl,!1):this._useHashChange&&!this.iframe?s("hashchange",this.checkUrl,!1):this._wantsHashChange&&(this._checkUrlInterval=setInterval(this.checkUrl,this.interval)),!this.options.silent)return this.loadUrl()},stop:function(){var t=window.removeEventListener||function(t,e){return detachEvent("on"+t,e)};this._usePushState?t("popstate",this.checkUrl,!1):this._useHashChange&&!this.iframe&&t("hashchange",this.checkUrl,!1),this.iframe&&(document.body.removeChild(this.iframe),this.iframe=null),this._checkUrlInterval&&clearInterval(this._checkUrlInterval),C.started=!1},route:function(t,e){this.handlers.unshift({route:t,callback:e})},checkUrl:function(t){var e=this.getFragment();if(e===this.fragment&&this.iframe&&(e=this.getHash(this.iframe.contentWindow)),e===this.fragment)return!1;this.iframe&&this.navigate(e),this.loadUrl()},loadUrl:function(e){return!!this.matchRoot()&&(e=this.fragment=this.getFragment(e),x.some(this.handlers,function(t){if(t.route.test(e))return t.callback(e),!0}))},navigate:function(t,e){if(!C.started)return!1;e&&!0!==e||(e={trigger:!!e}),t=this.getFragment(t||"");var i=this.root;""!==t&&"?"!==t.charAt(0)||(i=i.slice(0,-1)||"/");var n=i+t;if(t=this.decodeFragment(t.replace(N,"")),this.fragment!==t){if(this.fragment=t,this._usePushState)this.history[e.replace?"replaceState":"pushState"]({},document.title,n);else{if(!this._wantsHashChange)return this.location.assign(n);if(this._updateHash(this.location,t,e.replace),this.iframe&&t!==this.getHash(this.iframe.contentWindow)){var s=this.iframe.contentWindow;e.replace||(s.document.open(),s.document.close()),this._updateHash(s.location,t,e.replace)}}return e.trigger?this.loadUrl(t):void 0}},_updateHash:function(t,e,i){if(i){var n=t.href.replace(/(javascript:|#).*$/,"");t.replace(n+"#"+e)}else t.hash="#"+e}}),h.history=new C;m.extend=_.extend=T.extend=b.extend=C.extend=function(t,e){var i,n=this;return i=t&&x.has(t,"constructor")?t.constructor:function(){return n.apply(this,arguments)},x.extend(i,n,e),i.prototype=x.create(n.prototype,t),(i.prototype.constructor=i).__super__=n.prototype,i};var M=function(){throw new Error('A "url" property or function must be specified')},O=function(e,i){var n=i.error;i.error=function(t){n&&n.call(i.context,e,t,i),e.trigger("error",e,t,i)}};return h});
//# sourceMappingURL=backbone.min.js.map