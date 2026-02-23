<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="dc dcterms mods xalan xlink xsl">

  <xsl:include href="resource:xsl/mods-utils.xsl" />
  <xsl:include href="resource:xsl/mods2dc-mode-dc.xsl" />

  <xsl:template match="mods:mods" mode="dc-meta">
    <link rel="schema.DC" href="http://purl.org/dc/elements/1.1/" />
    <link rel="schema.DCTERMS" href="http://purl.org/dc/terms/" />

    <xsl:variable name="dc.xml">
      <xsl:apply-templates select="mods:titleInfo[1]" mode="dc" />

      <xsl:apply-templates select="mods:name[@type='personal']" mode="dc" />

      <xsl:apply-templates select="mods:genre[@type='intern']" mode="dc" />

      <xsl:apply-templates select="descendant-or-self::mods:dateIssued[not(ancestor::mods:relatedItem[not(@type='host')])][1]" mode="dc" />
      <xsl:apply-templates select="mods:originInfo/mods:dateOther" mode="dc" />

      <xsl:apply-templates select="mods:relatedItem[(@type='host') or (@type='series')]" mode="dc" />

      <xsl:apply-templates select="mods:originInfo[mods:edition|mods:place|mods:publisher]"  />
      <xsl:apply-templates select="descendant-or-self::mods:publisher[not(ancestor::mods:relatedItem[not(@type='host')])][1]" mode="dc" />

      <xsl:apply-templates select="mods:identifier|mods:location/mods:url|mods:location/mods:shelfLocator" mode="dc" />
      <xsl:apply-templates select="mods:note" mode="dc" />
      <xsl:apply-templates select="mods:abstract|mods:abstract/@xlink:href" mode="dc" />

      <xsl:apply-templates select="mods:physicalDescription/mods:extent" mode="dc" />

      <xsl:apply-templates select="mods:language/mods:languageTerm" mode="dc" />
      <xsl:apply-templates select="mods:accessCondition[@type='use and reproduction']" mode="dc" />

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
