// REQ-132: 执行当前源码，模拟生命周期和可控异步请求，不访问后端。
const fs = require('fs');
const vm = require('vm');
const path = require('path');
const root = path.resolve(__dirname, '../../../../../wds/wds-web');
const ts = require(path.join(root, 'node_modules/typescript'));
const deferred = () => { let resolve, reject; const promise = new Promise((a,b) => {resolve=a; reject=b}); return {promise,resolve,reject}; };
const flush = async () => { for(let i=0;i<12;i++) await Promise.resolve(); };
function setup() {
  const mounted=[], unmounted=[], watchers=[], timers=new Set(), listeners=new Set();
  const vue={ref:value=>({value}), onMounted:fn=>mounted.push(fn), onUnmounted:fn=>unmounted.push(fn), watch:(source,fn)=>watchers.push(fn)};
  const context={document:{hidden:false,addEventListener:(_,fn)=>listeners.add(fn),removeEventListener:(_,fn)=>listeners.delete(fn)},setInterval:fn=>{timers.add(fn);return fn},clearInterval:fn=>timers.delete(fn)};
  const cache={};
  function load(name) {
    if(cache[name]) return cache[name];
    const source=fs.readFileSync(path.join(root,'src/views/provider/dashboard/composables',name+'.ts'),'utf8');
    const js=ts.transpileModule(source,{compilerOptions:{module:ts.ModuleKind.CommonJS,target:ts.ScriptTarget.ES2020}}).outputText;
    const exports={};
    vm.runInNewContext('(function(require,exports){'+js+'})',context)(key=>key==='vue'?vue:load(key.replace('./','')),exports);
    return cache[name]=exports;
  }
  return {load,mounted,unmounted,watchers,timers,listeners};
}
(async()=>{
  const results=[];
  let s=setup(), d=deferred();
  s.load('usePolling').usePolling(()=>d.promise);
  const mount=s.mounted[0](); s.unmounted[0](); d.resolve(); await mount;
  results.push({case:'卸载发生在首拉完成前',expected:'定时器和监听均为0',actual:{timers:s.timers.size,listeners:s.listeners.size},pass:s.timers.size===0&&s.listeners.size===0});
  s=setup(); const a=deferred(),b=deferred();let calls=0;
  const polling=s.load('usePolling').usePolling(()=>++calls===1?a.promise:b.promise);
  const old=polling.refresh(), fresh=polling.refresh({force:true}); b.resolve();await fresh; a.reject(new Error('old request'));await old;
  results.push({case:'新请求成功后旧请求失败',expected:'error=false',actual:polling.error.value,pass:polling.error.value===false});
  s=setup(); const oldData=deferred(), newData=deferred();calls=0;let count=0;
  const dynamic=s.load('useDynamicModule').useDynamicModule(async()=>{const r=await (++calls===1?oldData.promise:newData.promise);count=r.total;return r;},{watchSource:()=>1});
  const initial=dynamic.refresh();s.watchers[0](2,1);newData.resolve({list:['B'],total:2});await flush();oldData.resolve({list:['A'],total:1});await initial;await flush();
  results.push({case:'列表版本守卫',expected:'B',actual:dynamic.list.value,pass:dynamic.list.value[0]==='B'});
  results.push({case:'fetchFn 内先写计数的旧请求',expected:2,actual:count,pass:count===2});
  s=setup();calls=0;const failed=deferred();
  const mod=s.load('useDynamicModule').useDynamicModule(()=>++calls===1?Promise.resolve({list:['A'],total:1}):failed.promise,{watchSource:()=>1});
  await mod.refresh();s.watchers[0](2,1);failed.reject(new Error('B failed'));await flush();
  results.push({case:'切主体后新请求失败',expected:'不展示A主体列表',actual:{list:mod.list.value,error:mod.error.value},pass:mod.list.value.length===0});
  console.log(JSON.stringify({method:'源码转译执行，Vue hooks和定时器为受控替身；非浏览器端到端测试',results},null,2));
  process.exitCode=results.every(x=>x.pass)?0:1;
})();
