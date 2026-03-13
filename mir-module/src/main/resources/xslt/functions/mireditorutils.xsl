<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:mireditorutils="http://www.mycore.de/xslt/mireditorutils"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mireditorutils:serialize-node" as="xs:string">
    <xsl:param name="node" as="node()" />
    <xsl:sequence select="serialize($node, map { 'method': 'xml', 'omit-xml-declaration': true() })" />
  </xsl:function>

  <xsl:function name="mireditorutils:is-valid-object-id" as="xs:boolean">
    <xsl:param name="value" as="xs:string?" />
    <xsl:variable name="normalized" select="normalize-space($value)" />
    <xsl:variable name="matches-pattern"
      select="string-length($normalized) le 64
              and matches($normalized, '^[A-Za-z][A-Za-z0-9]*_[A-Za-z0-9]+_[0-9]+$')" />
    <xsl:variable name="type"
      select="if ($matches-pattern) then lower-case(tokenize($normalized, '_')[2]) else ''" />
    <xsl:sequence
      select="$matches-pattern and mcrproperty:one(concat('MCR.Metadata.Type.', $type)) = 'true'" />
  </xsl:function>

  <xsl:function name="mireditorutils:build-extent-pages" as="element(mods:extent)">
    <xsl:param name="input" as="xs:string?" />
    <xsl:variable name="value" select="mireditorutils:normalize-hyphens(normalize-space($input))" />
    <xsl:choose>
      <xsl:when test="matches($value, '^(?:[sSpP]{1,2}\.?\s*)?([A-Za-z0-9.]+)\s*-\s*([A-Za-z0-9.-]+)\.?$')">
        <xsl:variable name="start" select="replace($value, '^(?:[sSpP]{1,2}\.?\s*)?([A-Za-z0-9.]+)\s*-\s*([A-Za-z0-9.-]+)\.?$', '$1')" />
        <xsl:variable name="end"
          select="replace(replace($value, '^(?:[sSpP]{1,2}\.?\s*)?([A-Za-z0-9.]+)\s*-\s*([A-Za-z0-9.-]+)\.?$', '$2'), '\.$', '')" />
        <mods:extent unit="pages">
          <mods:start><xsl:value-of select="$start" /></mods:start>
          <mods:end><xsl:value-of select="mireditorutils:complete-end-page($start, $end)" /></mods:end>
        </mods:extent>
      </xsl:when>
      <xsl:when test="matches($value, '^(?:[sSpP]{1,2}\.?\s*)?([A-Za-z0-9.]+)\s*\((\d+)\s*(?:pages|[Ss]eiten|S\.)\)$')">
        <mods:extent unit="pages">
          <mods:start>
            <xsl:value-of select="replace($value, '^(?:[sSpP]{1,2}\.?\s*)?([A-Za-z0-9.]+)\s*\((\d+)\s*(?:pages|[Ss]eiten|S\.)\)$', '$1')" />
          </mods:start>
          <mods:total>
            <xsl:value-of select="replace($value, '^(?:[sSpP]{1,2}\.?\s*)?([A-Za-z0-9.]+)\s*\((\d+)\s*(?:pages|[Ss]eiten|S\.)\)$', '$2')" />
          </mods:total>
        </mods:extent>
      </xsl:when>
      <xsl:when test="matches($value, '^(?:[sSpP]{1,2}\.?\s*)?([A-Za-z0-9.]+)(?:\s+ff?\.?)$')">
        <mods:extent unit="pages">
          <mods:start>
            <xsl:value-of select="replace($value, '^(?:[sSpP]{1,2}\.?\s*)?([A-Za-z0-9.]+)(?:\s+ff?\.?)$', '$1')" />
          </mods:start>
        </mods:extent>
      </xsl:when>
      <xsl:when test="matches($value, '^\(?([A-Za-z0-9.]+)\s*(?:pages|[Ss]eiten|S\.)\)?$')">
        <mods:extent unit="pages">
          <mods:total>
            <xsl:value-of select="replace($value, '^\(?([A-Za-z0-9.]+)\s*(?:pages|[Ss]eiten|S\.)\)?$', '$1')" />
          </mods:total>
        </mods:extent>
      </xsl:when>
      <xsl:otherwise>
        <mods:extent unit="pages">
          <mods:list><xsl:value-of select="$value" /></mods:list>
        </mods:extent>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mireditorutils:normalize-hyphens" as="xs:string">
    <xsl:param name="input" as="xs:string?" />
    <xsl:sequence select="translate($input, '&#x2010;&#x2011;&#x2012;&#x2013;&#x2015;&#x2212;&#x2E3B;&#xFE58;&#xFE63;', '---------')" />
  </xsl:function>

  <xsl:function name="mireditorutils:complete-end-page" as="xs:string">
    <xsl:param name="start" as="xs:string" />
    <xsl:param name="end" as="xs:string" />
    <xsl:choose>
      <xsl:when test="matches($start, '^\d+$') and matches($end, '^\d+$') and string-length($start) gt string-length($end)">
        <xsl:sequence select="concat(substring($start, 1, string-length($start) - string-length($end)), $end)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$end" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
