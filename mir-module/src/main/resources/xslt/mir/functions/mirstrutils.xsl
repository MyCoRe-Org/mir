<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:mirstrutils="http://www.mycore.de/xslt/mirstrutils"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:variable name="mirstrutils:html-entity-map" as="map(xs:string, xs:string)"
    select="map {
      'quot': codepoints-to-string(34),
      'amp': codepoints-to-string(38),
      'apos': codepoints-to-string(39),
      'lt': codepoints-to-string(60),
      'gt': codepoints-to-string(62),
      'nbsp': codepoints-to-string(160),
      'ccedil': codepoints-to-string(231),
      'Ccedil': codepoints-to-string(199),
      'Beta': codepoints-to-string(914)
    }" />

  <xsl:variable name="mirstrutils:xml-entity-map" as="map(xs:string, xs:string)"
    select="map {
      'quot': codepoints-to-string(34),
      'amp': codepoints-to-string(38),
      'apos': codepoints-to-string(39),
      'lt': codepoints-to-string(60),
      'gt': codepoints-to-string(62)
    }" />

  <xsl:function name="mirstrutils:escape-xml" as="xs:string?">
    <xsl:param name="input" as="xs:string?" />
    <xsl:sequence select="
      if (empty($input)) then $input
      else string-join(
        for $cp in string-to-codepoints($input)
        return
          if ($cp = 34) then '&amp;quot;'
          else if ($cp = 38) then '&amp;amp;'
          else if ($cp = 39) then '&amp;apos;'
          else if ($cp = 60) then '&amp;lt;'
          else if ($cp = 62) then '&amp;gt;'
          else if ($cp gt 127) then concat('&amp;#', $cp, ';')
          else codepoints-to-string($cp),
        ''
      )" />
  </xsl:function>

  <xsl:function name="mirstrutils:unescape-xml" as="xs:string?">
    <xsl:param name="input" as="xs:string?" />
    <xsl:sequence select="mirstrutils:unescape-entities($input, $mirstrutils:xml-entity-map)" />
  </xsl:function>

  <xsl:function name="mirstrutils:unescape-html" as="xs:string?">
    <xsl:param name="input" as="xs:string?" />
    <xsl:sequence select="mirstrutils:unescape-entities($input, $mirstrutils:html-entity-map)" />
  </xsl:function>

  <xsl:function name="mirstrutils:unescape-entities" as="xs:string?">
    <xsl:param name="input" as="xs:string?" />
    <xsl:param name="entity-map" as="map(xs:string, xs:string)" />
    <xsl:choose>
      <xsl:when test="empty($input)">
        <xsl:sequence select="$input" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="value" select="string($input)" />
        <xsl:variable name="result" as="xs:string*">
          <xsl:analyze-string select="$value" regex="&amp;(#(?:x|X)[0-9A-Fa-f]+|#\d+|[A-Za-z][A-Za-z0-9]+);">
            <xsl:matching-substring>
              <xsl:variable name="entity" select="regex-group(1)" />
              <xsl:choose>
                <xsl:when test="starts-with($entity, '#x') or starts-with($entity, '#X')">
                  <xsl:sequence select="codepoints-to-string(mirstrutils:hex-to-integer(substring($entity, 3)))" />
                </xsl:when>
                <xsl:when test="starts-with($entity, '#')">
                  <xsl:sequence select="codepoints-to-string(xs:integer(substring($entity, 2)))" />
                </xsl:when>
                <xsl:when test="map:contains($entity-map, $entity)">
                  <xsl:sequence select="map:get($entity-map, $entity)" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="." />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:sequence select="." />
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string-join($result, '')" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mirstrutils:hex-to-integer" as="xs:integer">
    <xsl:param name="hex" as="xs:string" />
    <xsl:sequence select="
      fold-left(
        string-to-codepoints(upper-case($hex)),
        0,
        function($value as xs:integer, $cp as xs:integer) as xs:integer {
          $value * 16 +
          (if ($cp ge 48 and $cp le 57) then $cp - 48 else $cp - 55)
        }
      )" />
  </xsl:function>

</xsl:stylesheet>
