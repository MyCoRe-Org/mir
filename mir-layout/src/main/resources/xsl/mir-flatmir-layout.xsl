<?xml version="1.0" encoding="utf-8"?>
  <!-- ============================================== -->
  <!-- $Revision$ $Date$ -->
  <!-- ============================================== -->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:i18ntr="http://www.mycore.org/i18n"
  exclude-result-prefixes="xlink i18ntr">

  <xsl:strip-space elements="*" />
  <xsl:include href="mir-flatmir-layout-utils.xsl" />
  <xsl:param name="MIR.DefaultLayout.CSS" />
  <xsl:param name="MIR.CustomLayout.CSS" select="''" />
  <xsl:param name="MIR.CustomLayout.JS" select="''" />
  <xsl:param name="MIR.Layout.Theme" />

  <xsl:variable name="PageTitle" select="/*/@title" />

  <xsl:template match="/site">
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
          <xsl:call-template name="mir.navigation" />
          <noscript>
            <div class="mir-no-script alert alert-warning text-center" style="border-radius: 0;">
              <i18ntr:code>mir.noScript.text</i18ntr:code>&#160;
              <a href="http://www.enable-javascript.com/de/" target="_blank">
                <i18ntr:code>mir.noScript.link</i18ntr:code>
              </a>
              .
            </div>
          </noscript>
        </header>
        <!-- include Internet Explorer warning -->
        <xsl:call-template name="msie-note" />

        <xsl:call-template name="mir.jumbotwo" />

        <section>
          <div class="container" id="page">
            <div id="main_content">
              <xsl:call-template name="print.writeProtectionMessage" />
              <xsl:call-template name="print.statusMessage" />

              <xsl:choose>
                <xsl:when test="$readAccess='true'">
                  <xsl:if test="breadcrumb/ul[@class='breadcrumb']">
                    <div class="row detail_row bread_plus">
                      <div class="col-12">
                        <ul itemprop="breadcrumb" class="breadcrumb">
                          <li class="breadcrumb-item">
                            <a class="navtrail" href="{$WebApplicationBaseURL}">
                              <i18ntr:code>mir.breadcrumb.home</i18ntr:code>
                            </a>
                          </li>
                          <xsl:copy-of select="breadcrumb/ul[@class='breadcrumb']/*" />
                        </ul>
                      </div>
                    </div>
                  </xsl:if>
                  <xsl:copy-of select="*[not(name()='head')][not(name()='breadcrumb')] " />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="printNotLoggedIn" />
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </div>
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
              title: "<i18ntr:code>mir.confirm.title</i18ntr:code>",
              confirmButton: "<i18ntr:code>mir.confirm.confirmButton</i18ntr:code>",
              cancelButton: "<i18ntr:code>mir.confirm.cancelButton</i18ntr:code>",
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
  <xsl:param name="RequestURL" />
</xsl:stylesheet>
