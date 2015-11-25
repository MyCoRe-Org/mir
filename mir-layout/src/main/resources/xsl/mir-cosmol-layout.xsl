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
  <xsl:strip-space elements="*" />
  <xsl:include href="resource:xsl/mir-cosmol-layout-utils.xsl"/>
  <xsl:param name="MIR.DefaultLayout.CSS" select="'cosmo.min'" />
  <xsl:param name="MIR.CustomLayout.CSS" select="''" />
  <xsl:param name="MIR.CustomLayout.JS" select="''" />
  <xsl:param name="MIR.Layout.Theme" select="'cosmol'" />
  <xsl:param name="MCR.NameOfProject" select="'MIR'" />

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
        <link href="{$WebApplicationBaseURL}assets/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
        <script type="text/javascript" src="{$WebApplicationBaseURL}mir-layout/assets/jquery/jquery.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}mir-layout/assets/jquery/plugins/jquery-migrate/jquery-migrate.min.js"></script>
        <xsl:copy-of select="head/*" />
        <link href="{$WebApplicationBaseURL}mir-layout/css/{$MIR.Layout.Theme}/{$MIR.DefaultLayout.CSS}.css" rel="stylesheet" />
        <script type="text/javascript" src ="{$WebApplicationBaseURL}mir-layout/js/cosmol.js"></script>
        <xsl:if test="string-length($MIR.CustomLayout.CSS) &gt; 0">
          <link href="{$WebApplicationBaseURL}css/{$MIR.CustomLayout.CSS}" rel="stylesheet" />
        </xsl:if>
        <xsl:if test="string-length($MIR.CustomLayout.JS) &gt; 0">
          <script type="text/javascript" src="{$WebApplicationBaseURL}js/{$MIR.CustomLayout.JS}"></script>
        </xsl:if>
        <xsl:call-template name="mir.prop4js" />
      </head>

      <body>

        <header>
          <div id="head" class="container">
            <div class="row">
              <div id="header_back">
                <img id="header_ratio" src="{$WebApplicationBaseURL}mir-layout/images/cosmol/header_ratio_117x18.png" />
                <a id="header_top" href="{$WebApplicationBaseURL}">
                    <img id="logo_ratio" src="{$WebApplicationBaseURL}mir-layout/images/cosmol/logo_ratio_267x117.png" />
                    <span id="project_name">mods institutional repository</span>
                </a>
              </div>
            </div>
          </div>
        </header>

        <div class="container" id="page">
          <div class="row" id="main_content">

            <div id="side_nav_column" class="hidden-xs col-sm-3">
              <xsl:call-template name="mir.navigation" />
            </div>

            <div id="main_content_column" class="col-xs-12 col-sm-9">

              <div class="button_box">
                <button id="hide_side_button"
                        class="navbar-toggle"
                        type="button">
                  <span class="sr-only"> Hide side nav </span>
                  <span id="close-icon" class="glyphicon glyphicon-chevron-left"> </span>
                  <div id="menu-icon" class="">
                    <span class="icon-bar"> </span>
                    <span class="icon-bar"> </span>
                    <span class="icon-bar"> </span>
                  </div>
                </button>
                <xsl:call-template name="mir.top-navigation" />
              </div>

              <div class="row detail_row bread_plus">
                <div class="col-xs-12">
                  <ul itemprop="breadcrumb" class="breadcrumb">
                    <li>
                      <a class="navtrail" href="{$WebApplicationBaseURL}"><xsl:value-of select="i18n:translate('mir.breadcrumb.home')" /></a>
                    </li>
                    <xsl:choose>
                      <xsl:when test="string-length($breadCrumb)>0">
                        <xsl:copy-of select="$breadCrumb" />
                      </xsl:when>
                      <xsl:when test="breadcrumb/ul[@class='breadcrumb']">
                        <xsl:copy-of select="breadcrumb/ul[@class='breadcrumb']/*" />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:call-template name="mir.breadcrumb" />
                      </xsl:otherwise>
                  </xsl:choose>
                  </ul>
                </div>
              </div>

              <xsl:call-template name="print.writeProtectionMessage" />
              <xsl:choose>
                <xsl:when test="$readAccess='true'">
                  <xsl:copy-of select="*[not(name()='head')][not(name()='breadcrumb')] " />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="printNotLoggedIn" />
                </xsl:otherwise>
              </xsl:choose>

            </div>
          </div>
        </div>

        <footer>
            <div class="container">
                <div id="menu" class="row">
                    <div class="col-xs-6">
                        <ul id="sub_menu">
                            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='brand']/item[@href='/content/brand/impressum.xml']" />
                            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='brand']/item[@href='/content/brand/contact.xml']" />
                        </ul>
                    </div>
                    <div class="col-xs-6">
                        <div id="copyright">© <xsl:value-of select="$MCR.NameOfProject" /> 2015</div>
                    </div>
                </div>
                <div id="credits" class="row">
                    <div class="col-xs-12">
                        <div id="powered_by">
                            <a href="http://www.mycore.de">
                                <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
                                <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_powered_120x30_blaue_schrift_frei.png" title="{$mcr_version}" alt="powered by MyCoRe"/>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </footer>

        <script type="text/javascript">
          <!-- Bootstrap & Query-Ui button conflict workaround  -->
          if (jQuery.fn.button){jQuery.fn.btn = jQuery.fn.button.noConflict();}
        </script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}assets/bootstrap/js/bootstrap.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}assets/jquery/plugins/jquery-confirm/jquery.confirm.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}js/mir/base.js"></script>
        <script>
          $( document ).ready(function() {
            $('.overtext').tooltip();
            $.confirm.options = {
              title: "<xsl:value-of select="i18n:translate('mir.confirm.title')" />",
              confirmButton: "<xsl:value-of select="i18n:translate('mir.confirm.confirmButton')" />",
              cancelButton: "<xsl:value-of select="i18n:translate('mir.confirm.cancelButton')" />",
              post: false,
              confirmButtonClass: "btn-danger",
              cancelButtonClass: "btn-default",
              dialogClass: "modal-dialog modal-lg" // Bootstrap classes for large modal
            }
          });
        </script>
        <!-- alco add placeholder for older browser -->
        <script src="{$WebApplicationBaseURL}assets/jquery/plugins/jquery-placeholder/jquery.placeholder.min.js"></script>
        <script>
          jQuery("input[placeholder]").placeholder();
          jQuery("textarea[placeholder]").placeholder();
        </script>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="/*[not(local-name()='site')]">
    <xsl:message terminate="yes">This is not a site document, fix your properties.</xsl:message>
  </xsl:template>
</xsl:stylesheet>