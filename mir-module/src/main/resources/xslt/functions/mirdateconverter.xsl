<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirdateconverter="http://www.mycore.de/xslt/mirdateconverter"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirdateconverter:convert-date" as="xs:string">
    <xsl:param name="date" as="xs:string?" />
    <xsl:param name="format" as="xs:string?" />
    <xsl:variable name="value" select="normalize-space($date)" />
    <xsl:variable name="kind" select="upper-case(normalize-space($format))" />
    <xsl:choose>
      <xsl:when test="$value = ''">
        <xsl:sequence select="$value" />
      </xsl:when>
      <xsl:when test="$kind = 'ISO8601'">
        <xsl:sequence select="mirdateconverter:convert-iso8601($value)" />
      </xsl:when>
      <xsl:when test="$kind = 'MARC'">
        <xsl:sequence select="mirdateconverter:convert-marc($value)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$value" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mirdateconverter:normalize-w3cdtf-to-utc" as="xs:string">
    <xsl:param name="value" as="xs:string?" />
    <xsl:variable name="normalized" select="normalize-space($value)" />
    <xsl:choose>
      <xsl:when test="$normalized = ''">
        <xsl:sequence select="''" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:try>
          <xsl:variable name="utc" select="adjust-dateTime-to-timezone(xs:dateTime($normalized), xs:dayTimeDuration('PT0H'))" />
          <xsl:sequence select="format-dateTime($utc, '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')" />
          <xsl:catch>
            <xsl:sequence select="$normalized" />
          </xsl:catch>
        </xsl:try>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mirdateconverter:convert-iso8601" as="xs:string">
    <xsl:param name="value" as="xs:string" />
    <xsl:choose>
      <xsl:when test="matches($value, '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$')">
        <xsl:sequence select="$value" />
      </xsl:when>
      <xsl:when test="matches($value, '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$')">
        <xsl:sequence select="concat($value, ':00')" />
      </xsl:when>
      <xsl:when test="matches($value, '^\d{4}-\d{2}-\d{2}T\d{2}$')">
        <xsl:sequence select="concat($value, ':00:00')" />
      </xsl:when>
      <xsl:when test="matches($value, '^\d{4}-\d{2}-\d{2}T\d{4}$')">
        <xsl:sequence select="replace($value, '^(\d{4}-\d{2}-\d{2}T\d{2})(\d{2})$', '$1:$2:00')" />
      </xsl:when>
      <xsl:when test="matches($value, '^\d{4}-\d{2}-\d{2}T\d{6}$')">
        <xsl:sequence select="replace($value, '^(\d{4}-\d{2}-\d{2}T\d{2})(\d{2})(\d{2})$', '$1:$2:$3')" />
      </xsl:when>
      <xsl:when test="matches($value, '^\d{8}T\d{6}$')">
        <xsl:sequence select="replace($value, '^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})$', '$1-$2-$3T$4:$5:$6')" />
      </xsl:when>
      <xsl:when test="matches($value, '^\d{8}T\d{4}$')">
        <xsl:sequence select="replace($value, '^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})$', '$1-$2-$3T$4:$5:00')" />
      </xsl:when>
      <xsl:when test="matches($value, '^\d{8}T\d{2}$')">
        <xsl:sequence select="replace($value, '^(\d{4})(\d{2})(\d{2})T(\d{2})$', '$1-$2-$3T$4:00:00')" />
      </xsl:when>
      <xsl:when test="matches($value, '^\d{8}$')">
        <xsl:sequence select="replace($value, '^(\d{4})(\d{2})(\d{2})$', '$1-$2-$3')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$value" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="mirdateconverter:convert-marc" as="xs:string">
    <xsl:param name="value" as="xs:string" />
    <xsl:choose>
      <xsl:when test="matches($value, '^\d{14}$')">
        <xsl:sequence select="replace($value, '^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$', '$1-$2-$3T$4:$5:$6')" />
      </xsl:when>
      <xsl:when test="matches($value, '^\d{12}$')">
        <xsl:sequence select="replace($value, '^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})$', '$1-$2-$3T$4:$5:00')" />
      </xsl:when>
      <xsl:when test="matches($value, '^\d{10}$')">
        <xsl:sequence select="replace($value, '^(\d{4})(\d{2})(\d{2})(\d{2})$', '$1-$2-$3T$4:00:00')" />
      </xsl:when>
      <xsl:when test="matches($value, '^\d{8}$')">
        <xsl:sequence select="replace($value, '^(\d{4})(\d{2})(\d{2})$', '$1-$2-$3')" />
      </xsl:when>
      <xsl:when test="matches($value, '^\d{6}$')">
        <xsl:sequence select="replace($value, '^(\d{4})(\d{2})$', '$1-$2')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$value" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
