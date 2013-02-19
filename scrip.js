function (a,e){
  if("object"===typeof a && a.length) {
    for(var d=0; d<a.length; d++)
      a[d] = h(a[d],e);
      return a
  }
  e = e || {};
  if(!e.from) e.from=b.settings.from;
  if(!e.to)
    e.to = b.settings.to;
  var d = e.to, c = e.from, f = b.rates;
  f[b.base]=1;

  if(!f[d] || !f[c]) 
    throw"fx error";
  d=c===b.base ? f[d] : d===b.base ? 1/f[c] : f[d] * (1/f[c]) ;
  return a * d
}
