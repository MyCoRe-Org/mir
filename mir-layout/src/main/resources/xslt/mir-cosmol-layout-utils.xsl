<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrversion="http://www.mycore.de/xslt/mcrversion"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="resource:xslt/layout/mir-common-layout.xsl" />

  <xsl:template  name="mir.header">
    <div id="header_box" class="clearfix container">
      <div id="options_nav_box" class="mir-prop-nav">
        <nav>
          <ul class="navbar-nav ms-auto flex-row">
            <xsl:call-template name="mir.loginMenu" />
            <xsl:call-template name="mir.languageMenu" />
          </ul>
        </nav>
      </div>
      <div id="project_logo_box">
        <a href="{concat($WebApplicationBaseURL,substring($loaded_navigation_xml/@hrefStartingPage,2))}"
           class="">
          <span id="logo_mir">mir</span>
          <span id="logo_modul">mycore</span>
          <span id="logo_slogan">mods institutional repository</span>
        </a>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.navigation">
    <div class="navbar navbar-default mir-side-nav searchfield_box">
      <nav class="mir-main-nav-entries">

        <form
          action="{$WebApplicationBaseURL}servlets/solr/find"
          class="searchfield_box form-inline my-2 my-lg-0"
          role="search">
          <div class="input-group">
            <input
              name="condQuery"
              placeholder="{mcri18n:translate('mir.navsearch.placeholder')}"
              class="form-control search-query"
              id="searchInput"
              type="text"
              aria-label="Search"
              aria-describedby="" />
            <xsl:choose>
              <xsl:when test="contains($isSearchAllowedForCurrentUser, 'true')">
                <input name="owner" type="hidden" value="createdby:*" />
              </xsl:when>
              <xsl:when test="not(mcracl:is-current-user-guest-user())">
                <input name="owner" type="hidden" value="createdby:{$CurrentUser}" />
              </xsl:when>
            </xsl:choose>
            <div class="input-group mb-3">
              <div class="input-group-append">
                <button type="submit" class="btn btn-primary">
                  <i class="fas fa-search"></i>
                </button>
              </div>
            </div>
          </div>
        </form>
        <ul class="nav navbar-nav">
          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='main']" />
          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='search']" />
          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='browse']" />
          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='publish']" />
          <xsl:call-template name="mir.basketMenu" />
          <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='misc']" />
        </ul>
      </nav>
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
            <li><a href="#"><button type="button" class="social_icons social_icon_x"></button>X</a></li>
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
    <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrversion:complete-version())" />
    <div id="powered_by">
      <a href="http://www.mycore.de">
        <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
      </a>
    </div>
  </xsl:template>

</xsl:stylesheet>
