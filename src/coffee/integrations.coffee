# Facebook
do (d = document, s = "script", id = "facebook-jssdk") ->
  js = undefined
  fjs = d.getElementsByTagName(s)[0]
  return  if d.getElementById(id)
  js = d.createElement(s)
  js.id = id
  js.src = "//connect.facebook.net/en_GB/all.js#xfbml=1&appId=623816767664793"
  fjs.parentNode.insertBefore js, fjs
