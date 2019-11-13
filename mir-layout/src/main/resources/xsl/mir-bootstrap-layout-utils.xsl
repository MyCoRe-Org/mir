<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                exclude-result-prefixes="i18n mcrver mcrxsl">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl"/>
  <xsl:template name="mir.navigation">

    <nav class="navbar navbar-light bg-light">
      <div id="header_box" class="container">
        <a href="{concat($WebApplicationBaseURL,substring($loaded_navigation_xml/@hrefStartingPage,2),$HttpSession)}"
           class="navbar-brand">
          <span id="logo_mir" class="text-uppercase mr-2">mir</span>
          <span id="logo_modul" class="text-muted mr-2 d-none d-lg-inline">MyCoRe</span>
          <span id="logo_slogan" class="text-capitalize d-none d-lg-inline">MODS institutional repository</span>
        </a>
        <ul class="navbar-nav ml-auto flex-row">
          <xsl:call-template name="mir.loginMenu"/>
          <xsl:call-template name="mir.languageMenu"/>
        </ul>
      </div>
    </nav>

    <!-- Collect the nav links, forms, and other content for toggling -->

    <nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow">
      <div class="container">
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#mir-main-nav-entries">
          <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="mir-main-nav-entries">
          <ul class="navbar-nav mr-auto">
            <xsl:for-each select="$loaded_navigation_xml/menu">
              <xsl:choose>
                <xsl:when test="@id='main'"/> <!-- Ignore some menus, they are shown elsewhere in the layout -->
                <xsl:when test="@id='brand'"/>
                <xsl:when test="@id='below'"/>
                <xsl:when test="@id='user'"/>
                <xsl:otherwise>
                  <xsl:apply-templates select="."/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
            <xsl:call-template name="mir.basketMenu"/>
          </ul>
          <form action="{$WebApplicationBaseURL}servlets/solr/find" class="searchfield_box form-inline my-2 my-lg-0"
                role="search">
            <input name="condQuery" aria-label="{i18n:translate('mir.navsearch.placeholder')}"
                   placeholder="{i18n:translate('mir.navsearch.placeholder')}"
                   class="form-control mr-sm-1 w-auto" id="searchInput" type="search"/>
            <xsl:choose>
              <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')">
                <input name="owner" type="hidden" value="createdby:*"/>
              </xsl:when>
              <xsl:when test="not(mcrxsl:isCurrentUserGuestUser())">
                <input name="owner" type="hidden" value="createdby:{$CurrentUser}"/>
              </xsl:when>
            </xsl:choose>
            <button type="submit" class="btn btn-secondary my-2 my-sm-0">
              <i class="fas fa-search"></i>
            </button>
          </form>
        </div>
      </div><!-- /container -->
    </nav>
  </xsl:template>

  <xsl:template name="mir.jumbotwo">
    <!-- show only on startpage -->
    <xsl:if test="//div/@class='jumbotwo'">
      <div class="jumbotron">
        <div class="container">
          <h1 class="display-4">Mit MIR wird alles gut!</h1>
          <p class="lead">your repository - just out of the box</p>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="mir.footer">
    <div class="col-4">
      <h6>Über uns</h6>
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
      <h6>Navigation</h6>
      <ul class="list-unstyled internal_links">
        <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='brand']/item" mode="linkList"/>
      </ul>
    </div>
    <div class="col-2">
      <h6>Netzwerke</h6>
      <ul class="list-unstyled social_links">
        <li>
          <a href="#"><i class="social_icons social_icon_fb"></i>Facebook
          </a>
        </li>
        <li>
          <a href="#"><button type="button" class="social_icons social_icon_tw"></button>Twitter
          </a>
        </li>
        <li>
          <a href="#"><button type="button" class="social_icons social_icon_gg"></button>Google+
          </a>
        </li>
      </ul>
    </div>
    <div class="col-2">
      <h6>Layout based on</h6>
      <ul class="list-unstyled">
        <li>
          <a href="http://getbootstrap.com/">Bootstrap</a>
        </li>
        <li>
          <a href="http://bootswatch.com/">Bootswatch</a>
        </li>
      </ul>
    </div>
  </xsl:template>

  <xsl:template name="mir.powered_by">
    <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())"/>
    <div id="powered_by" class="col-12 text-center">
      <a href="http://www.mycore.de">
        <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png" title="{$mcr_version}"
             alt="powered by MyCoRe"/>
      </a>
    </div>
  </xsl:template>

  <xsl:template match="item" mode="linkList">
    <xsl:param name="active" select="descendant-or-self::item[@href = $browserAddress ]"/>
    <xsl:param name="url">
      <xsl:choose>
        <!-- item @type is "intern" -> add the web application path before the link -->
        <xsl:when
            test=" starts-with(@href,'http:') or starts-with(@href,'https:') or starts-with(@href,'mailto:') or starts-with(@href,'ftp:')">
          <xsl:value-of select="@href"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="UrlAddSession">
            <xsl:with-param name="url" select="concat($WebApplicationBaseURL,substring-after(@href,'/'))"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <li>
      <a href="{$url}">
        <xsl:if test="$active">
          <xsl:attribute name="class">
            <xsl:value-of select="'text-muted'"/>
          </xsl:attribute>
        </xsl:if>
        <!-- linkText from mir-navigation.xsl -->
        <xsl:apply-templates select="." mode="linkText"/>
      </a>
    </li>

  </xsl:template>

</xsl:stylesheet>
