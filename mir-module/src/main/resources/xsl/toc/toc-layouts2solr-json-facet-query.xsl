<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="encoder">

  <xsl:param name="MIR.TableOfContents.MaxResults" select="'1000'" />
  <xsl:param name="MIR.TableOfContents.LevelLimit" select="'100'" />
  <xsl:param name="MIR.TableOfContents.FieldsUsed" select="'*'" />

  <xsl:template match="/toc-layouts">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select="toc-layout" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="toc-layout">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:text>&amp;fl=</xsl:text>
      <xsl:value-of select="encoder:encode($MIR.TableOfContents.FieldsUsed,'UTF-8')" />
      <xsl:text>&amp;rows=</xsl:text>
      <xsl:value-of select="$MIR.TableOfContents.MaxResults" />
      <xsl:text>&amp;sort=</xsl:text>
      <xsl:apply-templates select="descendant::*[@field][@order]" mode="sort" />
      <xsl:for-each select="descendant::level">
        <xsl:text>&amp;toc.</xsl:text>
        <xsl:value-of select="@field" />
        <xsl:text>.expanded=</xsl:text>
        <xsl:value-of select="@expanded" />
        <xsl:if test="@displayField">
          <xsl:text>&amp;toc.</xsl:text>
          <xsl:value-of select="@field"/>
          <xsl:text>.displayField=</xsl:text>
          <xsl:value-of select="@displayField"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>&amp;json.facet=</xsl:text>
      <xsl:variable name="json.facet">
        <xsl:text>{</xsl:text>
        <xsl:call-template name="publications.json" />
        <xsl:apply-templates select="level" mode="json" />
        <xsl:text>}</xsl:text>
      </xsl:variable>
      <xsl:value-of select="encoder:encode($json.facet,'UTF-8')" />
    </xsl:copy>
  </xsl:template>

  <!-- build solr param for sort order of returned documents -->
  <xsl:template match="*" mode="sort">
    <xsl:value-of select="concat(@field,'+',@order)" />
    <xsl:if test="position() != last()">,</xsl:if>
  </xsl:template>

  <!-- build solr json for facet of publication ids at this level -->
  <xsl:template name="publications.json">
    <xsl:text>docs:{type:terms,field:id,limit:</xsl:text>
    <xsl:value-of select="$MIR.TableOfContents.MaxResults" />
    <xsl:if test="level">
      <xsl:text>,domain:{filter:"</xsl:text> <!-- exclude all ids that will occur at any sub-level -->
      <xsl:for-each select="descendant::level">
        <xsl:value-of select="concat('-',@field,':[* TO *]')" />
        <xsl:if test="level">
          <xsl:value-of select="' AND '" />
        </xsl:if>
      </xsl:for-each>
      <xsl:text>"}</xsl:text>
    </xsl:if>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- build solr json for a toc level as facet -->
  <!-- pass-through the default expanded state of level encoded as part of the facet name -->
  <xsl:template match="level" mode="json">
    <xsl:text>,</xsl:text>
    <xsl:value-of select="@field" />
    <xsl:text>:{type:terms,limit:</xsl:text>
    <xsl:choose>
      <xsl:when test="@limit">
        <xsl:value-of select="@limit" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$MIR.TableOfContents.LevelLimit" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="concat(',field:',@field)" />
    <xsl:value-of select="concat(',sort:{index:',@order,'}')" />
    <xsl:text>,facet:{</xsl:text>
    <xsl:call-template name="publications.json" />
    <xsl:apply-templates select="level" mode="json" />
    <xsl:text>}}</xsl:text>
  </xsl:template>

</xsl:stylesheet>
