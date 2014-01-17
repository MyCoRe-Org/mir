<?xml version="1.0" encoding="utf-8"?>
  <!-- ============================================== -->
  <!-- $Revision$ $Date$ -->
  <!-- ============================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager" xmlns:mcr="http://www.mycore.org/" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" exclude-result-prefixes="xlink basket actionmapping mcr mcrver mcrxsl i18n">
  <xsl:output method="html" doctype-system="about:legacy-compat" indent="yes" omit-xml-declaration="yes" media-type="text/html"
    version="5" />
  <xsl:include href="resource:xsl/layout/mir-common-layout.xsl"/>
  <xsl:variable name="wcms.useTargets" select="'no'" />
  

  <!-- any XML elements defined here will go into the head -->
  <!-- other stylesheets may override this variable -->
  <xsl:variable name="head.additional" />

  <!-- ============================================== -->
  <!-- the template                                   -->
  <!-- ============================================== -->
  <xsl:template name="template_mir">
    <html lang="{$CurrentLang}" class="no-js">
      <head>
        <meta charset="utf-8" />
        <title>
          <xsl:call-template name="PageTitle" />
        </title>
        <xsl:comment>
          Mobile viewport optimisation
        </xsl:comment>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link href="{$WebApplicationBaseURL}templates/master/{$template}/CSS/layout.css" rel="stylesheet" type="text/css" />
        <xsl:apply-templates select="/" mode="addHeader" />
        <xsl:call-template name="module-broadcasting.getHeader" />
        <script src="{$WebApplicationBaseURL}js/modernizr.custom.49632.js" type="text/javascript"></script>
      </head>

      <body>
        <div id="wrapper">
          <header>
            <xsl:call-template name="mir.navigation" />
          </header>
          <a name="All" />
          <div class="container">
            <div id="main">
              <xsl:call-template name="mir.write.content" />
            </div>
          </div>
        </div>
        <footer role="contentinfo">
          <div class="container">
            <div class="row">
              <div class="col-md-8">
                <ul class="footer-links dropup">
                  <li>
                    <xsl:value-of select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
                  </li>
                  <li class="text-muted">&#183;</li>
                  <xsl:call-template name="mir.languageMenu" />
                </ul>
                <p>
                  Layout based on
                  <a href="http://getbootstrap.com/">Bootstrap</a>
                  ―
                  <a href="http://fortawesome.github.com/Font-Awesome">Font Awesome</a>
                  by Dave Gandy
                </p>
              </div>
              <div class="col-md-4 text-right">
                <p>
                  ©
                  <a href="http://www.mycore.de">
                    <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/logo_mycore.svg" style="height:0.8em" title="Logo von MyCoRe"
                      alt="MyCoRe" />
                  </a>
                  Community
                </p>
              </div>
            </div>
          </div>
        </footer>
        <xsl:copy-of select="$head.additional" />
        <script src="{$WebApplicationBaseURL}templates/master/{$template}/bootstrap/js/bootstrap.js"></script>
        <script>
        	<!-- Bootstrap & Query-Ui button conflict workaround  -->
          jQuery.fn.btn = jQuery.fn.button.noConflict();
        </script>
        <script src="{$WebApplicationBaseURL}templates/master/{$template}/JS/base.js" type="text/javascript" />
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>