{%- if page.comments %}
{%- set gitment_css_uri = theme.vendors.gitment_css or '//imsun.github.io/gitment/style/default.css' %}
<link rel="stylesheet" href="{{ gitment_css_uri }}">

{%- set gitment_js_uri = theme.vendors.gitment_js or '//imsun.github.io/gitment/dist/gitment.browser.js' %}
<script src="{{ gitment_js_uri }}"></script>

<script>
var gitment = new Gitment({
  owner: '{{ theme.gitment.githubID }}',
  repo: '{{ theme.gitment.repo }}',
  oauth: {
    client_id: '{{ theme.gitment.ClientID }}',
    client_secret: '{{ theme.gitment.ClientSecret }}',
  },
})
gitment.render('container')
</script>
{%- endif %}