<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="actionmapping">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />

  <xsl:template name="mir.top-navigation">
  <div class="navbar navbar-default mir-prop-nav">
    <nav class="mir-prop-nav-entries">
      <ul class="nav navbar-nav pull-right">
        <xsl:call-template name="mir.loginMenu" />
      </ul>
    </nav>
  </div>
  </xsl:template>

  <xsl:template name="mir.navigation">
    <div class="navbar navbar-default mir-side-nav">
      <nav class="mir-main-nav-entries">
        <div id="project_home_link">
          <!-- TODO: do it i18n -->
          <a href="{$WebApplicationBaseURL}">Start</a>
        </div>
        <form action="{$WebApplicationBaseURL}servlets/solr/find?qry={0}" class="navbar-form form-inline" role="search">
          <div class="form-group">
            <input name="qry" placeholder="Suche" class="form-control search-query" id="searchInput" type="text" />
          </div>
          <button type="submit" class="btn btn-primary"><span class="glyphicon glyphicon-search"></span></button>
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

</xsl:stylesheet>