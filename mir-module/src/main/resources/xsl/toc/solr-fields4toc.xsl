<?xml version="1.0" encoding="UTF-8"?>

<!-- Builds solr fields used for table of contents -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  exclude-result-prefixes="xalan xlink mods">
  
  <xsl:import href="xslImport:solr-document:toc/solr-fields4toc.xsl" />

  <xsl:template match="mycoreobject">
    <xsl:apply-imports />
    <xsl:for-each select="metadata/def.modsContainer/modsContainer/mods:mods">
      <xsl:apply-templates select="." mode="toc" />
      <xsl:apply-templates select="mods:relatedItem[contains('host series',@type)]" mode="toc" />
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mods:mods" mode="toc">
    <xsl:for-each select="mods:titleInfo[not(@type)][not(@altFormat)][1]">
      <field name="mir.toc.title">
        <xsl:for-each select="mods:nonSort">
          <xsl:value-of select="text()" />
          <xsl:text> </xsl:text>      
        </xsl:for-each>
        <xsl:value-of select="mods:title" />
        <xsl:for-each select="mods:subTitle">
          <xsl:text>: </xsl:text>      
          <xsl:value-of select="text()" />
        </xsl:for-each>
      </field>
    </xsl:for-each>
    <xsl:if test="mods:name[@type='personal'][contains('cre aut edt',mods:role/mods:roleTerm)]">
      <field name="mir.toc.authors">
        <xsl:for-each select="mods:name[@type='personal'][contains('cre aut edt',mods:role/mods:roleTerm)]">
          <xsl:choose>
            <xsl:when test="mods:displayForm">
              <xsl:value-of select="mods:displayForm" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="mods:namePart[@type='family']" />
              <xsl:for-each select="mods:namePart[@type='given']">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="text()" />
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="position() != last()">; </xsl:if>
        </xsl:for-each>
      </field>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mods:relatedItem[contains('host series',@type)]" mode="toc">

    <xsl:for-each select="@xlink:href">
      <field name="mir.toc.ancestor">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
    
    <xsl:for-each select="mods:part">
    
      <!-- mir.toc.host.order, mir.toc.series.order -->
      <xsl:for-each select="@order">
        <field name="mir.toc.{../../@type}.order">
          <xsl:value-of select="number(.)" />
        </field>
      </xsl:for-each>
      
      <!-- mir.toc.host.volume, mir.toc.host.issue, mir.toc.series.volume etc. -->
      <xsl:for-each select="mods:detail[@type]">
        <field name="mir.toc.{../../@type}.{@type}">
          <xsl:value-of select="mods:number" />
        </field>
      </xsl:for-each>
      
      <!-- mir.toc.host.page.str, mir.toc.host.page.int -->
      <xsl:for-each select="mods:extent[@unit='pages']">
        <xsl:variable name="number" select="string(number(normalize-space(mods:start)))" />
        <xsl:choose>
          <xsl:when test="$number = 'NaN'">
            <field name="mir.toc.{../../@type}.page.str">
              <xsl:value-of select="mods:start" />
            </field>
          </xsl:when>
          <xsl:otherwise>
            <field name="mir.toc.{../../@type}.page.int">
              <xsl:value-of select="$number" />
            </field>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>
