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
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[contains('host series',@type)]" mode="toc" />
  </xsl:template>
  
  <xsl:template match="mods:relatedItem[contains('host series',@type)]" mode="toc">
    <xsl:apply-templates select="mods:relatedItem[contains('host series',@type)]" mode="toc" />
 
    <xsl:for-each select="@xlink:href">
      <field name="ancestor">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
    
    <xsl:for-each select="mods:part">
    
      <!-- host.order, series.order -->
      <xsl:for-each select="@order">
        <field name="{../../@type}.order">
          <xsl:value-of select="number(.)" />
        </field>
      </xsl:for-each>
      
      <!-- host.volume, host.issue, series.volume etc. -->
      <xsl:for-each select="mods:detail[@type]">
        <field name="{../../@type}.{@type}">
          <xsl:value-of select="mods:number" />
        </field>
      </xsl:for-each>
      
      <!-- host.page.str, host.page.int -->
      <xsl:for-each select="mods:extent[@unit='pages']">
        <xsl:variable name="number" select="string(number(normalize-space(mods:start)))" />
        <xsl:choose>
          <xsl:when test="$number = 'NaN'">
            <field name="{../../@type}.page.str">
              <xsl:value-of select="mods:start" />
            </field>
          </xsl:when>
          <xsl:otherwise>
            <field name="{../../@type}.page.int">
              <xsl:value-of select="$number" />
            </field>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>