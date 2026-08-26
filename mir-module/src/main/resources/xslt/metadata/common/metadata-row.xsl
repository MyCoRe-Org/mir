<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template name="meta-row-from-nodes">
    <xsl:param name="nodes" as="node()*" />
    <xsl:param name="label-key" as="xs:string?" />
    <xsl:param name="label" as="xs:string?" />
    <xsl:param name="sep" select="''" as="xs:string" />
    <xsl:param name="value-property" as="xs:string?" />
    <xsl:param name="filter" select="true()" as="xs:boolean" />

    <xsl:variable name="filtered" select="
      if ($filter)
      then $nodes[not(@xml:lang) or @xml:lang = mcri18n:select-present-lang($nodes)]
      else $nodes
    " />

    <xsl:if test="exists($filtered)">
      <xsl:variable name="value">
        <xsl:call-template name="joined-values">
          <xsl:with-param name="nodes" select="$filtered" />
          <xsl:with-param name="sep" select="$sep" />
        </xsl:call-template>
      </xsl:variable>

      <xsl:call-template name="meta-row">
        <xsl:with-param name="label-key" select="$label-key" />
        <xsl:with-param name="label" select="$label" />
        <xsl:with-param name="value" select="$value" />
        <xsl:with-param name="value-property" select="$value-property" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="meta-row">
    <xsl:param name="label-key" as="xs:string?" />
    <xsl:param name="label" as="xs:string?" />
    <xsl:param name="value" as="item()*" />
    <xsl:param name="value-property" as="xs:string?" />

    <xsl:if test="exists($value)">
      <xsl:variable name="resolved-label" select="
      if ($label) then $label
      else if ($label-key) then mcri18n:translate($label-key)
      else error(xs:QName('err:missing-label'), 'meta-row: label or label-key required')
    " />

      <dt class="metaname">
        <xsl:value-of select="$resolved-label" />
      </dt>
      <dd class="metavalue">
        <xsl:if test="$value-property">
          <xsl:attribute name="property" select="$value-property" />
        </xsl:if>
        <xsl:copy-of select="$value" />
      </dd>
    </xsl:if>
  </xsl:template>

  <xsl:template name="joined-values">
    <xsl:param name="nodes" as="node()*" />
    <xsl:param name="sep" select="''" as="xs:string" />

    <xsl:for-each select="$nodes">
      <xsl:if test="position() != 1">
        <xsl:choose>
          <xsl:when test="string-length($sep) &gt; 0">
            <xsl:value-of select="$sep" />
          </xsl:when>
          <xsl:otherwise>
            <br />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <xsl:apply-templates select="." mode="value-content" />
      <xsl:apply-templates select="." mode="value-suffix" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="node()" mode="value-content">
    <xsl:call-template name="lf2br">
      <xsl:with-param name="string" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="node()" mode="value-suffix" />

  <xsl:template name="lf2br">
    <xsl:param name="string" as="xs:string" />

    <xsl:for-each select="tokenize($string, '\r?\n')">
      <xsl:value-of select="." />
      <xsl:if test="position() ne last()">
        <br />
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
