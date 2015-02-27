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
        <xsl:if test="string-length($MIR.CustomLayout.JS) &gt; 0">
          <script type="text/javascript" src="{$WebApplicationBaseURL}js/{$MIR.CustomLayout.JS}"></script>
        </xsl:if>
      </head>

      <body>

        <header>
          <div id="head" class="container">
            <div class="row">
              <div id="header_back">
                <a id="header_top" href="{$WebApplicationBaseURL}">
                    <span id="project_name">mods institutional repository</span>
                </a>
              </div>
            </div>
            <div class="row">
              <xsl:call-template name="mir.top-navigation" />
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
                  <span class="glyphicon glyphicon-chevron-left"> </span>
                  <div id="menu-icon" class="">
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
        <script type="text/javascript" src="//netdna.bootstrapcdn.com/bootstrap/{$bootstrap.version}/js/bootstrap.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}js/jquery.confirm.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}js/mir/base.js"></script>
        <script>

          /*
           * load side nav settings from session
           */
          function setSideNav() {
            if ( typeof(Storage) !== "undefined" ) {
              switch ( localStorage.getItem("sideNav") ) {
                case 'opened':
                  if ( !$('#side_nav_column').is(":visible") ) {
                    toggleSideNav(0);
                  }
                  break;
                case 'closed':
                  if ( $('#side_nav_column').is(":visible") ) {
                    toggleSideNav(0);
                  }
                  break;
                case null:
                  if ( $('#side_nav_column').is(":visible") ) {
                    localStorage.setItem("sideNav", "opened");
                  } else {
                    localStorage.setItem("sideNav", "opened");
                  }
                  break;
                default:
              }
            }
          }

          /*
           * adjust main content columns
           * depending from visibility of side nav
           */
          function adjustColumns() {

          // define elements
          var mainCol  = $('#main_content_column');                  // parent
          var leftCol  = $('#main_content_column #main_col');        // left child
          var rightCol = $('#main_content_column #aux_col');         // right child

          // scale or enlarge elements
            if ( $('#side_nav_column').is(":visible") ) {
              // side nav is visible, make one column
              mainCol.removeClass('col-sm-12').addClass('col-sm-9');   // parent
              leftCol.removeClass('col-md-8').addClass('col-xs-12');   // left
              rightCol.removeClass('col-md-4').addClass('col-xs-12');  // right
            } else {
              // side nav is hidden, make two columns
              mainCol.removeClass( 'col-sm-9').addClass( 'col-sm-12'); // parent
              leftCol.removeClass( 'col-xs-12').addClass('col-md-8');  // left
              rightCol.removeClass('col-xs-12').addClass('col-md-4');  // right
            }
          }

          /*
           * adjust toggle button for site menu
           * depending from visibility of side nav
           * not only controlled by js, but also by css
           */
          function adjustMenuButton() {
              if ( $('#side_nav_column').is(":visible") ) {
                // site nav is visible now
                // hide menu button
                $('#hide_side_button #menu-icon').hide();
              // show close button
                $('#hide_side_button .glyphicon-chevron-left').show();
              } else {
                // site nav is hidden now
                // show menu button
                $('#hide_side_button #menu-icon').show();
                // hide close button
                $('#hide_side_button .glyphicon-chevron-left').hide();
              }
          }

          /*
           * toggle side nav
           */
          function toggleSideNav(speed) {
            if( speed === undefined ) {
              speed = 'slow';
            }
            if ( $('#side_nav_column').is(":visible") ) {
              // site nav is visible
              // hide menu
              $('#side_nav_column').hide(speed, function() {
                adjustColumns();
                adjustMenuButton();
              });
              if ( typeof(Storage) !== "undefined" ) {
                localStorage.setItem("sideNav", "closed");
              }
            } else {
              // site nav is hidden
              // make it visible
              $('#side_nav_column').show('slow');
              $('#side_nav_column').removeClass('hidden-xs');
              $('#side_nav_column').addClass('col-xs-12');
              adjustColumns();
              adjustMenuButton();
              if ( typeof(Storage) !== "undefined" ) {
                localStorage.setItem("sideNav", "opened");
              }
            }
          }

          $( document ).ready(function() {

            // load side nav settings from session
            setSideNav();

            // if side nav hidden/shown
            adjustColumns();
            adjustMenuButton();

            $( window ).resize(function() {
              // if side nav hidden/shown
              adjustColumns();
              adjustMenuButton();
            });

            $('#hide_side_button').click(function(){
              toggleSideNav();
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