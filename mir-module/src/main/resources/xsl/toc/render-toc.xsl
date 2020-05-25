<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xsl xalan i18n">

  <xsl:param name="WebApplicationBaseURL" />
  
  <!-- custom layouts of level items and publications -->
  <xsl:include href="toc/custom-toc-layouts.xsl" />

  <xsl:include href="coreFunctions.xsl" />

  <xsl:template match="toc">
    <!-- show table of contents only if the response returned any documents -->
    <xsl:if test="//doc">
      <div id="toc" class="detail_block">
        <h3>
          <xsl:value-of select="i18n:translate('mir.metadata.content')"/>

          <!-- links to expand/collapse all toc levels at once -->
          <xsl:if test="count(//item) &gt; 1">          
            <span class="float-right" style="font-size:smaller;">
              <a id="tocShowAll" href="#">
                <xsl:value-of select="i18n:translate('mir.abstract.showGroups')" />
              </a>
              <a id="tocHideAll" href="#" style="display:none;">
                <xsl:value-of select="i18n:translate('mir.abstract.hideGroups')" />
              </a>
            </span>
          </xsl:if>
        </h3>
        
        <!-- show all toc levels and publications  -->
        <xsl:apply-templates select="level|publications" />
        
        <!-- javascript to expand/collapse toc levels on click -->
        <script src="{$WebApplicationBaseURL}js/mir/toc-layout.js" />
      </div>
    </xsl:if>
  </xsl:template>

  <!-- if at top level, there is only one group, without deeper levels, just show publications -->
  <xsl:template match="toc/level[count(item)=1][item[not(level)][publications]]" priority="1">
    <xsl:apply-templates select="item/publications" />
  </xsl:template>

  <!-- show a toc level -->
  <xsl:template match="level">
    <ol style="list-style-type: none;">
      <xsl:for-each select="item">
        
        <xsl:variable name="id" select="generate-id()" />
        
        <xsl:variable name="expanded">
          <xsl:choose>
            <xsl:when test="(../@expanded='first') and (position()=1)">true</xsl:when>
            <xsl:otherwise><xsl:value-of select="../@expanded" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <li>
          <xsl:choose>
            <!-- if there are deeper levels below, prepare expand/collapse functionality -->
            <xsl:when test="level|publications">
            
              <a href="#{$id}" data-toggle="collapse" aria-expanded="{$expanded}" aria-controls="{$id}" style="margin-right:1ex;">
                <span>
                  <xsl:attribute name="class">
                    <xsl:text>toggle-collapse fas fa-fw </xsl:text>
                    <xsl:choose>
                      <xsl:when test="$expanded='true'">fa-chevron-down</xsl:when>
                      <xsl:otherwise>fa-chevron-right</xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </span>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <span class="fas fa-fw fa-chevron-right" style="margin-right:1ex;" />
            </xsl:otherwise>
          </xsl:choose>
          
          <!-- show this level item -->    
          <xsl:apply-templates select="." />                

          <!-- show level/publications below the current one -->
          <xsl:if test="level|publications">
            <div id="{$id}">
              <xsl:attribute name="class">
                <xsl:text>below collapse</xsl:text>
                <xsl:if test="$expanded='true'"> show</xsl:if>
              </xsl:attribute>
              <xsl:apply-templates select="level|publications" />
            </div>
          </xsl:if>
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>

  <!-- default template to show a toc level item (a group) -->
  <!-- may be overwritten by higher priority custom toc layout templates -->
  <xsl:template match="item">
   <xsl:apply-templates select="@value" />
   <xsl:apply-templates select="doc" />
  </xsl:template>
  
  <xsl:template match="item/@value">
    <span class="level.label" style="margin-right:1ex">
      <xsl:value-of select="." />
    </span>
  </xsl:template>

  <!-- show list of publications at current level -->  
  <xsl:template match="publications">
    <ul>
      <xsl:for-each select="doc">
        <xsl:sort select="@pos" data-type="number" order="ascending" />
        <li>
          <xsl:apply-templates select="." />
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>
  
  <!-- default template to show publication -->
  <!-- may be overwritten by higher priority custom toc layout templates -->
  <xsl:template match="doc">
    <a href="{$WebApplicationBaseURL}receive/{@id}">
      <xsl:value-of select="field[@name='mods.title.main']" />
    </a>
  </xsl:template>

</xsl:stylesheet>