<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager" xmlns:mcr="http://www.mycore.org/" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:layoutUtils="xalan:///org.mycore.frontend.MCRLayoutUtilities"
  exclude-result-prefixes="layoutUtils xlink basket actionmapping mcr mcrver mcrxsl i18n">
  <xsl:strip-space elements="*" />
  <xsl:param name="CurrentLang" select="'de'" />
  <xsl:param name="CurrentUser" />
  <xsl:param name="numPerPage" />
  <xsl:param name="previousObject" />
  <xsl:param name="previousObjectHost" />
  <xsl:param name="nextObject" />
  <xsl:param name="nextObjectHost" />
  <xsl:param name="resultListEditorID" />
  <xsl:param name="page" />
  <xsl:param name="breadCrumb" />
  <xsl:include href="layout-utils.xsl" />
  <xsl:include href="resource:xsl/layout/mir-navigation.xsl" />
  <xsl:variable name="loaded_navigation_xml" select="layoutUtils:getPersonalNavigation()/navigation" />
  <xsl:variable name="browserAddress">
    <xsl:call-template name="getBrowserAddress" />
  </xsl:variable>
  <xsl:variable name="whiteList">
    <xsl:call-template name="get.whiteList" />
  </xsl:variable>
  <xsl:variable name="readAccess">
    <xsl:choose>
      <xsl:when test="starts-with($RequestURL, $whiteList)">
        <xsl:value-of select="'true'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="layoutUtils:readAccess($browserAddress)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="mir.loginMenu">
    <xsl:variable xmlns:encoder="xalan://java.net.URLEncoder" name="loginURL"
      select="concat( $ServletsBaseURL, 'MCRLoginServlet',$HttpSession,'?url=', encoder:encode( string( $RequestURL ) ) )" />
    <xsl:choose>
      <xsl:when test="mcrxsl:isCurrentUserGuestUser()">
        <li>
          <a id="loginURL" href="{$loginURL}">
            <xsl:value-of select="i18n:translate('component.userlogin.button.login')" />
          </a>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <li class="dropdown">
          <a id="currentUser" class="dropdown-toggle" data-toggle="dropdown" href="#">
            <strong>
              <xsl:value-of select="$CurrentUser" />
            </strong>
            <span class="caret" />
          </a>
          <ul class="dropdown-menu" role="menu" aria-labelledby="dLabel">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='user']/*" />
          </ul>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mir.navigation">
    <div class="navbar-fixed-top container" id="mir-navbar-container">
      <nav class="navbar navbar-default navbar-mir">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse">
            <!-- TODO: translate -->
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <ul class="nav navbar-nav">
            <li class="dropdown">
              <a id="brandMenu" class="navbar-brand" href="#" data-toggle="dropdown">
                MIR
                <span class="caret" />
              </a>
              <ul class="dropdown-menu" role="menu" aria-labelledby="brandMenu">
                <li>
                  <a href="{concat($WebApplicationBaseURL,substring($loaded_navigation_xml/@hrefStartingPage,2),$HttpSession)}">Start</a>
                </li>
                <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='brand']/*" />
              </ul>
            </li>
          </ul>
        </div>
          <!-- Collect the nav links, forms, and other content for toggling -->
        <div class="collapse navbar-collapse navbar-ex1-collapse">
          <ul class="nav navbar-nav">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='search']" />
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='browse']" />
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='publish']" />
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='main']" />
            <xsl:call-template name="mir.basketMenu" />
            <xsl:call-template name="mir.searchMenu" />
          </ul>
          <ul id="userMenu" class="nav navbar-nav navbar-right">
            <xsl:call-template name="mir.loginMenu" />
          </ul>
        </div><!-- /nav-collapse -->
      </nav>
    </div><!-- /container -->
  </xsl:template>
  <xsl:template name="mir.searchMenu">
    <!--
     -->
    <li role="search" class="visible-xs">
      <form class="navbar-form navbar-right" role="search" action="{$ServletsBaseURL}solr/find{$HttpSession}" method="get"
        onsubmit="return fireMirSSQuery(this)">
        <div class="form-group input-group">
          <input id="searchInput" type="text" name="qry" class="form-control search-query" placeholder="Suche">
            <xsl:variable name="qry" select="/response/lst/lst/str[@name='qry']" />
            <xsl:if test="$qry">
              <xsl:attribute name="value">
                <xsl:value-of select="$qry" />
              </xsl:attribute>
            </xsl:if>
          </input>
          <div class="input-group-btn">
            <button class="btn btn-default" type="submit">
              <i class="fa fa-search"></i>
            </button>
          </div>
        </div>
      </form>
    </li>
    <li role="search" id="navSearchContainer" class="hidden-xs">
      <div id="searchInputBox">
        <input id="searchInput" class="form-control search-query" type="text" data-url="{$ServletsBaseURL}solr/find{$HttpSession}?qry={{0}}"
          placeholder="Suche" name="qry">
          <xsl:variable name="qry" select="/response/lst/lst/str[@name='qry']" />
          <xsl:if test="$qry">
            <xsl:attribute name="value">
              <xsl:value-of select="$qry" />
            </xsl:attribute>
          </xsl:if>
        </input>
      </div>
      <a href="{actionmapping:getURLforCollection('search','simple',true())}">
        <i class="fa fa-search"></i>
      </a>
    </li>
  </xsl:template>
  <xsl:template name="mir.languageMenu">
    <li class="dropdown">
      <a data-toggle="dropdown" title="{i18n:translate('mir.language.change')}">
        <img alt="{$CurrentLang}" src="{$WebApplicationBaseURL}images/mir/lang-{$CurrentLang}.png" />
        <span class="caret" />
      </a>
      <ul class="dropdown-menu language-menu" role="menu" aria-labelledby="languageMenu">
        <xsl:if test="$CurrentLang!='de'">
          <li>
            <xsl:variable name="langURL">
              <xsl:call-template name="mir.languageLink">
                <xsl:with-param name="lang" select="'de'" />
              </xsl:call-template>
            </xsl:variable>
            <a href="{$langURL}" title="{i18n:translate('mir.language.de')}">
              <img alt="{i18n:translate('mir.language.de')}" src="{$WebApplicationBaseURL}images/mir/lang-de.png" />
            </a>
          </li>
        </xsl:if>
        <xsl:if test="$CurrentLang!='en'">
          <li>
            <xsl:variable name="langURL">
              <xsl:call-template name="mir.languageLink">
                <xsl:with-param name="lang" select="'en'" />
              </xsl:call-template>
            </xsl:variable>
            <a href="{$langURL}" title="{i18n:translate('mir.language.en')}">
              <img alt="{i18n:translate('mir.language.en')}" src="{$WebApplicationBaseURL}images/mir/lang-en.png" />
            </a>
          </li>
        </xsl:if>
      </ul>
    </li>
  </xsl:template>
  <xsl:template name="mir.languageLink">
    <xsl:param name="lang" />
    <xsl:variable name="langURL">
      <xsl:call-template name="UrlSetParam">
        <xsl:with-param name="url" select="$RequestURL" />
        <xsl:with-param name="par" select="'lang'" />
        <xsl:with-param name="value" select="$lang" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="UrlAddSession">
      <xsl:with-param name="url" select="$langURL" />
    </xsl:call-template>
  </xsl:template>
  <!-- ======================================================================================================== -->
  <xsl:template name="mir.write.content">
    <xsl:call-template name="print.writeProtectionMessage" />
    <xsl:choose>
      <xsl:when test="$readAccess='true'">
        <!-- xsl:call-template name="getFastWCMS" / -->
        <xsl:apply-templates />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="printNotLoggedIn" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mir.basketMenu">
    <xsl:variable name="basketType" select="'objects'" />
    <xsl:variable name="basket" select="document(concat('basket:',$basketType))/basket" />
    <xsl:variable name="entryCount" select="count($basket/entry)" />
    <li class="dropdown">
      <a class="dropdown-toggle" data-toggle="dropdown" href="#" title="{i18n:translate('basket.title.objects')}">
        <i class="fa fa-bookmark"></i>
        <sup>
          <xsl:value-of select="$entryCount" />
        </sup>
      </a>
      <ul class="dropdown-menu" role="menu" aria-labelledby="dLabel">
        <li class="disabled">
          <a>
            <xsl:choose>
              <xsl:when test="$entryCount = 0">
                <xsl:value-of select="i18n:translate('basket.numEntries.none')" disable-output-escaping="yes" />
              </xsl:when>
              <xsl:when test="$entryCount = 1">
                <xsl:value-of select="i18n:translate('basket.numEntries.one')" disable-output-escaping="yes" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="i18n:translate('basket.numEntries.many',$entryCount)" disable-output-escaping="yes" />
              </xsl:otherwise>
            </xsl:choose>
          </a>
        </li>
        <li class="divider" />
        <li>
          <a href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type={$basket/@type}&amp;action=show">
            <xsl:value-of select="i18n:translate('basket.open')" />
          </a>
        </li>
      </ul>
    </li>
  </xsl:template>
</xsl:stylesheet>