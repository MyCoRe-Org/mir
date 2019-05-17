<?xml version="1.0" encoding="UTF-8"?>

<!-- Custom table of contents layouts to display levels and publications -->

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
>

  <xsl:param name="CurrentLang" select="'de'" />

  <!-- "Vol. 67" -->
  <xsl:template match="toc[@layout='journal']//level[@field='host.volume']/item" priority="1">
    <xsl:value-of select="i18n:translate('mir.details.volume.journal')" />
    <xsl:text> </xsl:text> 
    <xsl:value-of select="@value" />
  </xsl:template>
  
  <!-- "No. 24" with link to object representing the complete issue -->
  <xsl:template match="toc[@layout='journal']//level[@field='host.issue']/item[doc]" priority="2">
    <a href="{$WebApplicationBaseURL}receive/{doc/@id}">
      <xsl:value-of select="i18n:translate('mir.details.issue')" />
      <xsl:text> </xsl:text>
      <xsl:value-of select="@value" />
    </a>
  </xsl:template>

  <!-- "No. 24" without link -->
  <xsl:template match="toc[@layout='journal']//level[@field='host.issue']/item" priority="1">
    <xsl:value-of select="i18n:translate('mir.details.issue')" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="@value" />
  </xsl:template>

  <!-- author, author: <br/> publication title with link | page number at right -->
  <xsl:template match="publications/doc" priority="1">
    <div style="display:table; width:100%;">
      <div style="display:table-cell; width:90%;">
        <xsl:for-each select="field[@name='mods.author']">
          <xsl:value-of select="." />
          <xsl:if test="position() != last()">, </xsl:if>
          <xsl:if test="position() = last()">:<br/></xsl:if>
        </xsl:for-each>
        <a href="{$WebApplicationBaseURL}receive/{@id}">
          <xsl:value-of select="field[@name='mods.title.main']" />
        </a>
      </div>
      <xsl:for-each select="field[starts-with(@name,'host.page')]">
        <div style="display:table-cell; width:10%;" class="text-right">
          <xsl:value-of select="i18n:translate('mir.pages.abbreviated.single')" />
          <xsl:text> </xsl:text>
          <xsl:value-of select="." />
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="toc[@layout='blog']//publications/doc" priority="2">
    <div style="display:table; width:100%;">
      <div style="display:table-cell; width:7ex;">
        <xsl:for-each select="field[@name='mods.dateIssued'][1]">
          <xsl:call-template name="formatISODate">
            <xsl:with-param name="date" select="." />
            <xsl:with-param name="format">
              <xsl:choose>
                <xsl:when test="$CurrentLang='de'">dd.MM.</xsl:when>
                <xsl:otherwise>MM-dd</xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
        <xsl:text> - </xsl:text>
      </div>
      <div style="display:table-cell;">
        <xsl:for-each select="field[@name='mods.author']">
          <xsl:value-of select="." />
          <xsl:if test="position() != last()">, </xsl:if>
          <xsl:if test="position() = last()">:<br/></xsl:if>
        </xsl:for-each>
        <a href="{$WebApplicationBaseURL}receive/{@id}">
          <xsl:value-of select="field[@name='mods.title.main']" />
        </a>
      </div>
    </div>
  </xsl:template>

 </xsl:stylesheet>