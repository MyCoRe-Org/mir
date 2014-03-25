<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="actionmapping">
  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />
  <xsl:template name="mir.navigation">

    <div class="navbar navbar-default mir-prop-nav">
      <div class="container">
        <div class="navbar-header">
          <button class="navbar-toggle" type="button" data-toggle="collapse" data-target=".mir-prop-nav-entries">
            <!-- TODO: translate -->
            <span class="sr-only"> Toggle navigation </span>
            <span class="icon-bar">
            </span>
            <span class="icon-bar">
            </span>
            <span class="icon-bar">
            </span>
          </button>
          <a href="{concat($WebApplicationBaseURL,substring($loaded_navigation_xml/@hrefStartingPage,2),$HttpSession)}" class="navbar-brand">
            <span id="logo_mir">mir</span>
            <span id="logo_modul">modul</span>
            <span id="logo_slogan">mycore/mods institutional repository</span>
          </a>
        </div>
        <nav class="collapse navbar-collapse mir-prop-nav-entries">
          <ul class="nav navbar-nav pull-right">
            <xsl:call-template name="mir.loginMenu" />
          </ul>
        </nav>
      </div>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="navbar navbar-default mir-main-nav">
      <div class="container">

        <div class="navbar-header">
          <button class="navbar-toggle" type="button" data-toggle="collapse" data-target=".mir-main-nav-entries">
            <span class="sr-only"> Toggle navigation </span>
            <span class="icon-bar">
            </span>
            <span class="icon-bar">
            </span>
            <span class="icon-bar">
            </span>
          </button>

        </div>
        <nav class="collapse navbar-collapse mir-main-nav-entries">
          <ul class="nav navbar-nav pull-left">
            <li class="dropdown">
              <a id="searchMenu" class="dropdown-toggle" data-toggle="dropdown" href="#">
                Suche
                <span class="caret" />
              </a>
              <ul class="dropdown-menu" role="menu" aria-labelledby="searchMenu">
                <xsl:call-template name="mir.navLink">
                  <xsl:with-param name="title" select="'einfach'" />
                  <xsl:with-param name="active" select="contains(@id,'start')" />
                  <xsl:with-param name="url" select="actionmapping:getURLforCollection('search','simple',true())" />
                </xsl:call-template>
                <xsl:call-template name="mir.navLink">
                  <xsl:with-param name="title" select="'komplex'" />
                  <xsl:with-param name="active" select="contains(@id,'search')" />
                  <xsl:with-param name="url" select="actionmapping:getURLforCollection('search','complex',true())" />
                </xsl:call-template>
                <xsl:call-template name="mir.navLink">
                  <xsl:with-param name="title" select="'expert'" />
                  <xsl:with-param name="active" select="contains(@id,'search-expert')" />
                  <xsl:with-param name="url" select="actionmapping:getURLforCollection('search','expert',true())" />
                </xsl:call-template>
              </ul>
            </li>
            <li class="dropdown">
              <a id="browseMenu" class="dropdown-toggle" data-toggle="dropdown" href="#">
                Blättern
                <span class="caret" />
              </a>
              <ul class="dropdown-menu" role="menu" aria-labelledby="browseMenu">
                <li>
                  <a href="{$WebApplicationBaseURL}content/main/classifications/mir_institutes.xml">Institutionen</a>
                </li>
                <li>
                  <a href="{$WebApplicationBaseURL}content/main/classifications/mir_genres.xml">Genre</a>
                </li>
              </ul>
            </li>
            <xsl:call-template name="mir.legacy-navigation">
              <xsl:with-param name="rootNode" select="$loaded_navigation_xml/navi-main" />
            </xsl:call-template>
            <xsl:call-template name="mir.basketMenu" />
                <!-- xsl:call-template name="mir.searchMenu" / -->
          </ul>
        </nav>
      </div><!-- /container -->
    </div>
  </xsl:template>
</xsl:stylesheet>