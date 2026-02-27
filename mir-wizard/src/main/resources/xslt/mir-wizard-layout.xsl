<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:mcrversion="http://www.mycore.de/xslt/version"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:output method="html" doctype-system="about:legacy-compat" indent="yes" omit-xml-declaration="yes" media-type="text/html" version="5" />
  <xsl:strip-space elements="*" />

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:variable name="PageTitle" select="/*/@title" />

  <xsl:template match="/site">
    <html lang="{$CurrentLang}" class="no-js">
      <head>
        <meta charset="utf-8" />
        <title>
          <xsl:value-of select="$PageTitle" />
        </title>
        <xsl:comment>
          Mobile viewport optimisation
        </xsl:comment>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link href="{$WebApplicationBaseURL}assets/font-awesome/css/all.min.css" rel="stylesheet" />
        <link href="{$WebApplicationBaseURL}rsc/sass/mir-layout/scss/{mcrproperty:one('MIR.Layout.Theme')}-{mcrproperty:one('MIR.DefaultLayout.CSS')}.css" rel="stylesheet" />

        <script type="text/javascript" src="{$WebApplicationBaseURL}assets/jquery/jquery.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}assets/bootstrap/js/bootstrap.bundle.min.js"></script>
        <xsl:copy-of select="head/*" />
      </head>

      <body>
        <div id="wrapper">
          <header>&#160;</header>
          <a name="All" />
          <div class="container">
            <div id="main">
              <xsl:copy-of select="*[not(name()='head')]" />
            </div>
          </div>
        </div>
        <footer role="contentinfo">
          <div class="container">
            <div class="row">
              <div class="col-md-8">
                <xsl:value-of select="concat('MyCoRe ', mcrversion:complete-version())" />
                <p>
                  Layout based on
                  <a href="http://getbootstrap.com/">Bootstrap</a>
                  ―
                  <a href="https://github.com/FortAwesome/Font-Awesome">Font Awesome</a>
                  by Dave Gandy
                </p>
              </div>
              <div class="col-md-4 text-end">
                <p>
                  ©
                  <a href="http://www.mycore.de">
                    <img src="http://www.mycore.de/images/mycore_logo_110x19_blaue_schrift_frei.png" style="height:0.8em" title="Logo von MyCoRe" alt="MyCoRe" />
                  </a>
                  Community
                </p>
              </div>
            </div>
          </div>
        </footer>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
