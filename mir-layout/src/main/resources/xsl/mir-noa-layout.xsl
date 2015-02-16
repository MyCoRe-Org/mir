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
  <xsl:include href="resource:xsl/mir-noa-layout-utils.xsl"/>
  <xsl:param name="MIR.DefaultLayout.CSS" select="'cosmo.min'" />
  <xsl:param name="MIR.CustomLayout.CSS" select="''" />
  <xsl:param name="MIR.Layout.Theme" select="'noa'" />
  <!-- Various versions -->
  <xsl:variable name="bootstrap.version" select="'3.3.1'" />
  <xsl:variable name="bootswatch.version" select="$bootstrap.version" />
  <xsl:variable name="fontawesome.version" select="'4.2.0'" />
  <xsl:variable name="jquery.version" select="'2.1.1'" />
  <xsl:variable name="jquery.migrate.version" select="'1.2.1'" />
  <!-- End of various versions -->
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
        <link href="//netdna.bootstrapcdn.com/font-awesome/{$fontawesome.version}/css/font-awesome.min.css" rel="stylesheet" />
        <script type="text/javascript" src="//code.jquery.com/jquery-{$jquery.version}.min.js"></script>
        <script type="text/javascript" src="//code.jquery.com/jquery-migrate-{$jquery.migrate.version}.min.js"></script>
        <xsl:copy-of select="head/*" />
        <link href="{$WebApplicationBaseURL}mir-layout/css/{$MIR.Layout.Theme}/{$MIR.DefaultLayout.CSS}.css" rel="stylesheet" />
        <xsl:if test="string-length($MIR.CustomLayout.CSS) &gt; 0">
          <link href="{$WebApplicationBaseURL}css/{$MIR.CustomLayout.CSS}" rel="stylesheet" />
        </xsl:if>
      </head>

      <body>

        <header>
          <div class="container" id="head">
            <div class="row">
              <img id="header_back" src="{$WebApplicationBaseURL}mir-layout/images/header.png" />
              <a href="{$WebApplicationBaseURL}">
                <img id="header_top" src="{$WebApplicationBaseURL}mir-layout/images/logo.png" />
              </a>
            </div>
            <div class="row">
              <xsl:call-template name="mir.top-navigation" />
            </div>
          </div>
        </header>

        <div class="container" id="page">
          <div class="row" id="main_content">
            <div id="side_nav_column" class="col-xs-3">
              <xsl:call-template name="mir.navigation" />
            </div>
            <div id="main_content_column" class="col-xs-9">
              <div class="button_box">
                <button id="hide_side_button"
                        class="navbar-toggle"
                        type="button">
                  <span class="sr-only"> Hide side nav </span>
                  <span class="glyphicon glyphicon-chevron-left"> </span>
                  <div id="menu-icon">
                    <span class="icon-bar"> </span>
                    <span class="icon-bar"> </span>
                    <span class="icon-bar"> </span>
                  </div>
                </button>
              </div>

              <xsl:call-template name="print.writeProtectionMessage" />
              <xsl:choose>
                <xsl:when test="$readAccess='true'">
                  <xsl:copy-of select="*[not(name()='head')]" />
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
                <div class="row">
                    <div class="col-xs-6">
                        <ul id="sub_menu">
                            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='brand']" />
                        </ul>
                    </div>
                    <div class="col-xs-6">
                        <div id="copyright">©NOA 2015</div>
                    </div>
                </div>
                <div class="row">
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
        <script type="text/javascript" src="//netdna.bootstrapcdn.com/bootstrap/{$bootstrap.version}/js/bootstrap.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}js/jquery.confirm.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}js/mir/base.js"></script>
        <script>
          $( document ).ready(function() {

            $('#hide_side_button').click(function(){
                if ( $('#side_nav_column').is(":visible") ) {
                    // hide
                    $('#hide_side_button .glyphicon-chevron-left').hide();
                    $('#hide_side_button #menu-icon').show();
                    $('#side_nav_column').hide('slow', function() {
                        $('#main_content_column').removeClass('col-xs-9');
                        $('#main_content_column').addClass('col-xs-12');
                    });
                } else {
                    // make visible
                    $('#side_nav_column').show('slow');
                    $('#main_content_column').removeClass('col-xs-12');
                    $('#main_content_column').addClass('col-xs-9');
                    $('#hide_side_button #menu-icon').hide();
                    $('#hide_side_button .glyphicon-chevron-left').show();
                }
            });

            $('.overtext').tooltip();
            $.confirm.options = {
              text: "<xsl:value-of select="i18n:translate('mir.confirm.text')" />",
              title: "<xsl:value-of select="i18n:translate('mir.confirm.title')" />",
              confirmButton: "<xsl:value-of select="i18n:translate('mir.confirm.confirmButton')" />",
              cancelButton: "<xsl:value-of select="i18n:translate('mir.confirm.cancelButton')" />",
              post: false
            }
          });
        </script>
        <!-- alco add placeholder for older browser -->
        <script src="{$WebApplicationBaseURL}js/jquery.placeholder.min.js"></script>
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