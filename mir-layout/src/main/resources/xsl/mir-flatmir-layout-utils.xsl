<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
    xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
    xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
    exclude-result-prefixes="i18n mcrver mcrxsl">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />

  <xsl:template name="mir.navigation">

    <div id="header_box" class="clearfix container">
      <div id="options_nav_box" class="mir-prop-nav">
        <nav>
          <ul class="navbar-nav ml-auto flex-row">
            <xsl:call-template name="mir.loginMenu" />
            <xsl:call-template name="mir.languageMenu" />
          </ul>
        </nav>
      </div>
      <div id="project_logo_box">
        <a href="{concat($WebApplicationBaseURL,substring($loaded_navigation_xml/@hrefStartingPage,2),$HttpSession)}"
           class="">
          <span id="logo_mir">mir</span>
          <span id="logo_modul">mycore</span>
          <span id="logo_slogan">mods institutional repository</span>
        </a>
      </div>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="mir-main-nav bg-primary">
      <div class="container">
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">

          <button
            class="navbar-toggler"
            type="button"
            data-toggle="collapse"
            data-target="#mir-main-nav-collapse-box"
            aria-controls="mir-main-nav-collapse-box"
            aria-expanded="false"
            aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
          </button>

          <div id="mir-main-nav-collapse-box" class="collapse navbar-collapse mir-main-nav__entries">
            <ul class="navbar-nav mr-auto mt-2 mt-lg-0">
              <xsl:for-each select="$loaded_navigation_xml/menu">
                <xsl:choose>
                  <!-- Ignore some menus, they are shown elsewhere in the layout -->
                  <xsl:when test="@id='main'"/>
                  <xsl:when test="@id='brand'"/>
                  <xsl:when test="@id='below'"/>
                  <xsl:when test="@id='user'"/>
                  <xsl:otherwise>
                    <xsl:apply-templates select="."/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
              <xsl:call-template name="mir.basketMenu" />
            </ul>

            <form
              action="{$WebApplicationBaseURL}servlets/solr/find"
              class="searchfield_box form-inline my-2 my-lg-0"
              role="search">
              <input
                name="condQuery"
                placeholder="{i18n:translate('mir.navsearch.placeholder')}"
                class="form-control mr-sm-2 search-query"
                id="searchInput"
                type="text"
                aria-label="Search" />
              <xsl:choose>
                <xsl:when test="contains($isSearchAllowedForCurrentUser, 'true')">
                  <input name="owner" type="hidden" value="createdby:*" />
                </xsl:when>
                <xsl:when test="not(mcrxsl:isCurrentUserGuestUser())">
                  <input name="owner" type="hidden" value="createdby:{$CurrentUser}" />
                </xsl:when>
              </xsl:choose>
              <button type="submit" class="btn btn-primary my-2 my-sm-0">
                <i class="fas fa-search"></i>
              </button>
            </form>

          </div>

        </nav>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.jumbotwo">
    <!-- show only on startpage -->
    <xsl:if test="//div/@class='jumbotwo'">
      <div class="jumbotron">
        <div class="container">
          <h1>Mit MIR wird alles gut!</h1>
          <h2>your repository - just out of the box</h2>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="mir.footer">
    <div class="container">
      <div class="row">
        <div class="col-4">
          <h4>Über uns</h4>
          <p>
            MIR ein klassicher institutioneller Publikations- bzw.
            Dokumentenserver. Es basiert auf dem Repository-Framework
            MyCoRe und dem Metadata Object Description Schema (MODS).
            <span class="read_more">
              <a href="http://mycore.de/generated/mir/">Mehr erfahren ...</a>
            </span>
          </p>
        </div>
        <div class="col-2">
          <h4>Navigation</h4>
          <ul class="internal_links">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='brand']/*" />
          </ul>
        </div>
        <div class="col-2">
          <h4>Netzwerke</h4>
          <ul class="social_links">
            <li><a href="#"><button type="button" class="social_icons social_icon_fb"></button>Facebook</a></li>
            <li><a href="#"><button type="button" class="social_icons social_icon_tw"></button>Twitter</a></li>
            <li><a href="#"><button type="button" class="social_icons social_icon_gg"></button>Google+</a></li>
          </ul>
        </div>
        <div class="col-2">
          <h4>Layout based on</h4>
          <ul class="internal_links">
            <li><a href="{$WebApplicationBaseURL}mir-layout/template/flatmir.xml">flatmir</a></li>
            <li><a href="http://getbootstrap.com/">Bootstrap</a></li>
            <li><a href="http://bootswatch.com/">Bootswatch</a></li>
          </ul>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.powered_by">
    <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
    <div id="powered_by">
      <a href="http://www.mycore.de">
        <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
      </a>
    </div>
  </xsl:template>

</xsl:stylesheet>
