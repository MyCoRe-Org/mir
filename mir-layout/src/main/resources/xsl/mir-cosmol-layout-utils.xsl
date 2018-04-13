<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  exclude-result-prefixes="i18n mcrver mcrxsl">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />

  <xsl:template  name="mir.header">
    <div id="head" class="container">
      <div class="row">
        <div id="header_back">
          <img id="header_ratio" src="{$WebApplicationBaseURL}mir-layout/images/cosmol/header_ratio_117x18.png" />
          <a id="header_top" href="{$WebApplicationBaseURL}">
            <img id="logo_ratio" src="{$WebApplicationBaseURL}mir-layout/images/cosmol/logo_ratio_267x117.png" />
            <span id="project_name">mods institutional repository</span>
          </a>
        </div>
        <noscript>
          <div class="mir-no-script alert alert-warning text-center" style="border-radius: 0;">
            <xsl:value-of select="i18n:translate('mir.noScript.text')" />&#160;
            <a href="http://www.enable-javascript.com/de/" target="_blank">
              <xsl:value-of select="i18n:translate('mir.noScript.link')" />
            </a>
            .
          </div>
        </noscript>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.top-navigation">
  <div class="navbar navbar-default mir-prop-nav">
    <nav class="mir-prop-nav-entries">
      <ul class="nav navbar-nav pull-right">
        <xsl:call-template name="mir.loginMenu" />
        <xsl:call-template name="mir.languageMenu" />
      </ul>
    </nav>
  </div>
  </xsl:template>

  <xsl:template name="mir.navigation">
    <div class="navbar navbar-default mir-side-nav searchfield_box">
      <nav class="mir-main-nav-entries">
        <form action="{$WebApplicationBaseURL}servlets/solr/find" class="navbar-form form-inline" role="search">
          <div class="form-group">
            <input name="condQuery" placeholder="{i18n:translate('mir.navsearch.placeholder')}" title="{i18n:translate('mir.cosmol.navsearch.title')}" class="form-control search-query" id="searchInput" type="text" />
            <xsl:choose>
                <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')">
                  <input name="owner" type="hidden" value="createdby:*" />
                </xsl:when>
                <xsl:when test="not(mcrxsl:isCurrentUserGuestUser())">
                  <input name="owner" type="hidden" value="createdby:{$CurrentUser}" />
                </xsl:when>
              </xsl:choose>
          </div>
          <button type="submit" title="{i18n:translate('mir.cosmol.navsearch.title')}" class="btn btn-primary"><span class="glyphicon glyphicon-search"></span></button>
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

  <xsl:template name="mir.footer">
    <div class="container">
        <div id="menu" class="row">
            <div class="col-xs-6">
                <ul id="sub_menu">
                    <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='below']/item[@href='/content/brand/impressum.xml']" />
                    <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='brand']/item[@href='/content/brand/contact.xml']" />
                </ul>
            </div>
            <div class="col-xs-6">
                <div id="copyright">© <xsl:value-of select="$MCR.NameOfProject" /> 2016</div>
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
  </xsl:template>

</xsl:stylesheet>