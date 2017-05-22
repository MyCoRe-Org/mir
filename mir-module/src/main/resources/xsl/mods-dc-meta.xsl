<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="xsl mods xlink xalan dc dcterms"
>

  <xsl:include href="mods-utils.xsl" />
  <xsl:include href="mods2dc.xsl" />

  <xsl:template match="mods:mods" mode="dc-meta">
    <link rel="schema.DC" href="http://purl.org/dc/elements/1.1/" />
    <link rel="schema.DCTERMS" href="http://purl.org/dc/terms/" />

    <xsl:variable name="dc.xml">
      <xsl:apply-templates select="mods:titleInfo[1]" />

      <xsl:apply-templates select="mods:name[@type='personal']" />

      <xsl:apply-templates select="mods:genre[@type='intern']" />

      <xsl:apply-templates select="descendant-or-self::mods:dateIssued[not(ancestor::mods:relatedItem[not(@type='host')])][1]" />
      <xsl:apply-templates select="mods:originInfo/mods:dateOther" />

      <xsl:apply-templates select="mods:relatedItem[(@type='host') or (@type='series')]" />

      <xsl:apply-templates select="mods:originInfo[mods:edition|mods:place|mods:publisher]"  />
      <xsl:apply-templates select="descendant-or-self::mods:publisher[not(ancestor::mods:relatedItem[not(@type='host')])][1]"  />

      <xsl:apply-templates select="mods:identifier|mods:location/mods:url|mods:location/mods:shelfLocator" />
      <xsl:apply-templates select="mods:note|mods:abstract" />
      <xsl:apply-templates select="mods:abstract|mods:abstract/@xlink:href" />

      <xsl:apply-templates select="mods:physicalDescription/mods:extent" />

      <xsl:apply-templates select="mods:language/mods:languageTerm" />
      <xsl:apply-templates select="mods:accessCondition[@type='use and reproduction']" />

    </xsl:variable>
    <xsl:apply-templates select="xalan:nodeset($dc.xml)/*" mode="dc-meta" />
  </xsl:template>

  <xsl:template match="dc:*|dcterms:*" mode="dc-meta">
    <meta>
      <xsl:apply-templates select="." mode="dc-meta-name" />
      <xsl:apply-templates select="@scheme" mode="dc-meta" />
      <xsl:copy-of select="@xml:lang" />
      <xsl:attribute name="content">
        <xsl:value-of select="text()" />
      </xsl:attribute>
    </meta>
  </xsl:template>

  <xsl:template match="dc:*" mode="dc-meta-name">
    <xsl:attribute name="name">
      <xsl:text>DC.</xsl:text>
      <xsl:value-of select="local-name()" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="dcterms:*" mode="dc-meta-name">
    <xsl:attribute name="name">
      <xsl:text>DCTERMS.</xsl:text>
      <xsl:value-of select="local-name()" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@scheme[starts-with(.,'dc:') or starts-with(.,'dcterms:')]" mode="dc-meta">
    <xsl:attribute name="scheme">
      <xsl:value-of select="translate(substring-before(.,':'),'dcterms','DCTERMS')" />
      <xsl:text>.</xsl:text>
      <xsl:value-of select="substring-after(.,':')" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@scheme" mode="dc-meta">
    <xsl:copy-of select="." />
  </xsl:template>

</xsl:stylesheet>
