<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:output method="xml" encoding="UTF-8" media-type="application/rss+xml" indent="yes" />

  <xsl:template match="/">
    <rss version="2.0">
      <xsl:apply-templates select="mycoreobject" mode="channel" />
    </rss>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="channel">
    <xsl:variable name="mods" select="metadata/def.modsContainer/modsContainer/mods:mods" />
    <xsl:variable name="generator" select="mcrproperty:get('MIR.RSS.Generator')" />
    <channel>
      <xsl:apply-templates select="$mods/mods:titleInfo[1]" />
      <xsl:call-template name="render-rss-link" />
      <xsl:apply-templates select="$mods/mods:abstract[normalize-space()][1]" />
      <xsl:apply-templates select="$mods/mods:language[mods:languageTerm[@type = 'code']][1]" />
      <xsl:if test="$generator">
        <generator>
          <xsl:value-of select="$generator" />
        </generator>
      </xsl:if>
      <docs>https://www.rssboard.org/rss-specification</docs>
      <xsl:variable name="query" select="concat('solr:q=', encode-for-uri(concat('series.root:', @ID)),
        '&amp;fl=id&amp;rows=20&amp;sort=', encode-for-uri('mods.dateIssued desc,mods.dateIssued.host desc'))" />
      <!-- the Solr query does not check permissions, so only readable objects are listed -->
      <xsl:for-each select="document($query)/response/result/doc/str[@name = 'id'][mcracl:check-permission(., 'read')]">
        <xsl:apply-templates select="document(concat('mcrobject:', .))/mycoreobject" mode="item" />
      </xsl:for-each>
    </channel>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="item">
    <xsl:variable name="mods" select="metadata/def.modsContainer/modsContainer/mods:mods" />
    <item>
      <xsl:apply-templates select="$mods/mods:titleInfo[1]" />
      <xsl:call-template name="render-rss-link" />
      <xsl:apply-templates select="$mods/mods:abstract[normalize-space()][1]" />
      <xsl:apply-templates select="service/servdates/servdate[@type = 'modifydate'][. castable as xs:dateTime]" />
      <guid>
        <xsl:value-of select="concat($WebApplicationBaseURL, 'receive/', @ID)" />
      </guid>
    </item>
  </xsl:template>

  <xsl:template name="render-rss-link">
    <link>
      <xsl:value-of select="concat($WebApplicationBaseURL, 'receive/', @ID)" />
    </link>
  </xsl:template>

  <xsl:template match="mods:titleInfo">
    <title>
      <xsl:value-of select="mods:nonSort, mods:title" separator=" " />
      <xsl:if test="mods:subTitle">
        <!-- separate the subtitle by a colon, unless the title ends with a punctuation mark -->
        <xsl:if test="not(matches(mods:title, '[?!.:,;-]$'))">
          <xsl:text>:</xsl:text>
        </xsl:if>
        <xsl:value-of select="concat(' ', mods:subTitle)" />
      </xsl:if>
    </title>
  </xsl:template>

  <xsl:template match="mods:abstract">
    <description>
      <xsl:value-of select="." />
    </description>
  </xsl:template>

  <xsl:template match="mods:language">
    <language>
      <xsl:value-of select="mods:languageTerm[@type = 'code'][1]" />
    </language>
  </xsl:template>

  <!-- RFC 822 date as required by RSS, e.g. Mon, 05 Oct 2026 12:00:00 +0200 -->
  <xsl:template match="servdate">
    <pubDate>
      <xsl:value-of
        select="format-dateTime(xs:dateTime(.), '[FNn,3-3], [D01] [MNn,3-3] [Y0001] [H01]:[m01]:[s01] [Z0000]', 'en', (), ())" />
    </pubDate>
  </xsl:template>

</xsl:stylesheet>
