<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:output method="html" indent="yes" media-type="text/html" version="5" />
  <xsl:strip-space elements="*" />
  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:include href="resource:xslt/mir-cosmol-layout-utils.xsl"/>
  <xsl:param name="MIR.DefaultLayout.CSS" />
  <xsl:param name="MIR.CustomLayout.CSS" select="''" />
  <xsl:param name="MIR.CustomLayout.JS" select="''" />
  <xsl:param name="MIR.Layout.Theme" />

  <xsl:variable name="PageTitle" select="/*/@title" />

  <xsl:template match="/site">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
    <html lang="{$CurrentLang}" class="no-js">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
        <title>
          <xsl:value-of select="$PageTitle" />
        </title>
        <link href="{$WebApplicationBaseURL}assets/font-awesome/css/all.min.css" rel="stylesheet" />
        <script src="{$WebApplicationBaseURL}mir-layout/assets/jquery/jquery.min.js"></script>
        <script src="{$WebApplicationBaseURL}mir-layout/assets/jquery/plugins/jquery-migrate/jquery-migrate.min.js"></script>
        <xsl:copy-of select="head/*" />
        <link href="{$WebApplicationBaseURL}rsc/sass/mir-layout/scss/{$MIR.Layout.Theme}-{$MIR.DefaultLayout.CSS}.css" rel="stylesheet" />
        <script type="text/javascript" src ="{$WebApplicationBaseURL}mir-layout/js/cosmol.js"></script>
        <xsl:if test="string-length($MIR.CustomLayout.CSS) &gt; 0">
          <link href="{$WebApplicationBaseURL}css/{$MIR.CustomLayout.CSS}" rel="stylesheet" />
        </xsl:if>
        <xsl:if test="string-length($MIR.CustomLayout.JS) &gt; 0">
          <script src="{$WebApplicationBaseURL}js/{$MIR.CustomLayout.JS}"></script>
        </xsl:if>
        <xsl:call-template name="mir.prop4js" />
      </head>

      <body>
        <xsl:if test="//div/@class='jumbotwo'">
          <xsl:attribute name="class">
            <xsl:text>mir-start_page</xsl:text>
          </xsl:attribute>
        </xsl:if>

        <header>
          <xsl:call-template name="mir.header" />
          <noscript>
            <div class="mir-no-script alert alert-warning text-center" style="border-radius: 0;">
              <xsl:value-of select="mcri18n:translate('mir.noScript.text')" />&#160;
              <a href="http://www.enable-javascript.com/de/" target="_blank">
                <xsl:value-of select="mcri18n:translate('mir.noScript.link')" />
              </a>
              .
            </div>
          </noscript>
        </header>

        <section>
          <div class="container" id="page">
            <a id="top" />
            <div id="main_content" class="row">

              <div id="side_nav_column" class="col-12 col-lg-3">
                <xsl:call-template name="mir.navigation" />
              </div>

              <div id="main_content_column" class="col-12 col-lg-9">

                <div class="button_box">
                  <button
                    class="btn btn-sm mir-navbar-toggle"
                    type="button"
                    aria-controls="side_nav_column"
                    aria-expanded="false"
                    aria-label="Toggle navigation">
                    <i class="fas fa-bars mir-menu-icon"></i>
                  </button>
                </div>

                <xsl:call-template name="print.writeProtectionMessage" />
                <xsl:call-template name="print.statusMessage" />
                <xsl:choose>
                  <xsl:when test="$readAccess='true'">
                    <xsl:if test="breadcrumb/ul[@class='breadcrumb']">
                      <div class="row detail_row bread_plus">
                        <div class="col-12">
                          <ul itemprop="breadcrumb" class="breadcrumb">
                            <li class="breadcrumb-item">
                              <a class="navtrail" href="{$WebApplicationBaseURL}"><xsl:value-of select="mcri18n:translate('mir.breadcrumb.home')" /></a>
                            </li>
                            <xsl:copy-of select="breadcrumb/ul[@class='breadcrumb']/*" />
                          </ul>
                        </div>
                      </div>
                    </xsl:if>
                    <xsl:call-template name="mir.jumbotwo" />
                    <xsl:copy-of select="*[not(name()='head')][not(name()='breadcrumb')] " />
                  </xsl:when>
                  <xsl:otherwise>
                    <div class="alert alert-danger">
                      <xsl:value-of select="mcri18n:translate('webpage.notLoggedIn')" disable-output-escaping="yes" />
                    </div>
                  </xsl:otherwise>
                </xsl:choose>
              </div>
            </div>
          </div>
          <a href="#top" class="btn back-to-top" aria-label="{mcri18n:translate('mir.backToTop.label')}">
            <i class="fas fa-chevron-circle-up" aria-hidden="true" />
          </a>
        </section>

        <footer class="flatmir-footer">
          <xsl:call-template name="mir.footer" />
          <xsl:call-template name="mir.powered_by" />
        </footer>

        <script>
          <!-- Bootstrap & Query-Ui button conflict workaround  -->
          if (jQuery.fn.button){jQuery.fn.btn = jQuery.fn.button.noConflict();}
        </script>
        <script src="{$WebApplicationBaseURL}assets/bootstrap/js/bootstrap.bundle.min.js"></script>
        <script src="{$WebApplicationBaseURL}assets/jquery/plugins/jquery-confirm/jquery.confirm.min.js"></script>
        <script src="{$WebApplicationBaseURL}js/mir/base.min.js"></script>
        <script>
          $( document ).ready(function() {
            $('.overtext').tooltip();
            $.confirm.options = {
              title: "<xsl:value-of select="mcri18n:translate('mir.confirm.title')" />",
              confirmButton: "<xsl:value-of select="mcri18n:translate('mir.confirm.confirmButton')" />",
              cancelButton: "<xsl:value-of select="mcri18n:translate('mir.confirm.cancelButton')" />",
              post: false,
              confirmButtonClass: "btn-danger",
              cancelButtonClass: "btn-secondary",
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
