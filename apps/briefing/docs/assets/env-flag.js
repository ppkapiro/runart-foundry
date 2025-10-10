(function(){
  var html = document.documentElement;
  var banner;
  function ensureBanner(text){
    if(!banner){
      banner = document.createElement('div');
      banner.className = 'env-banner';
      document.body.appendChild(banner);
    }
    banner.textContent = (text || '').toUpperCase();
  }
  function applyEnv(env){
    html.dataset.env = env;
    const isProd =
      env === 'prod' ||
      env === 'production' ||
      (typeof env === 'string' && env.toLowerCase() === 'production');
    if (isProd) {
      if (banner) banner.remove();
      return;
    }
    if (env === 'local' || env === 'preview') ensureBanner(env);
  }
  applyEnv('local'); // valor por defecto
  try {
    fetch('/api/whoami', {cache:'no-store'})
      .then(r => r.ok ? r.json() : null)
      .then(j => { if (j && j.env) applyEnv(String(j.env)); })
      .catch(()=>{});
  } catch(e){}
})();
