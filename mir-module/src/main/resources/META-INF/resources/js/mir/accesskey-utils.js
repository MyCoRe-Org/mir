function getParameterByName(name, url = window.location.href) {
  name = name.replace(/[\[\]]/g, '\\$&');
  var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'), results = regex.exec(url);
  if (!results)
    return undefined;
  if (!results[2])
    return undefined;
  return decodeURIComponent(results[2].replace(/\+/g, ' '));
}
function generateKey(plength) {
  const keylistalpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const keylistint = "123456789";
  let temp = '';
  let len = plength / 2;
  len = len - 1;
  const lenspec = plength - len - len;
  for (let i = 0; i < len; i++)
    temp += keylistalpha.charAt(Math.floor(Math.random() * keylistalpha.length));
  for (let i = 0; i < len; i++)
    temp += keylistint.charAt(Math.floor(Math.random() * keylistint.length));
  temp = temp.split('').sort(function () {
    return 0.5 - Math.random();
  }).join('');
  return temp;
}
function isValidValue(value) {
  const regex = /[ !@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/g;
  return value.length != 0 && !regex.test(value);
}
