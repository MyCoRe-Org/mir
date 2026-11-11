<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='place']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.placeTerm'" />
      <xsl:with-param name="nodes" select="$mods/mods:originInfo[
        not(@eventType)
        or @eventType='publication']/mods:place/mods:placeTerm[not(@authority='marccountry')
      ]" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="field[@name='place.creation']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.placeTerm.creation'" />
      <xsl:with-param name="nodes" select="
        $mods/mods:originInfo[@eventType='creation']/mods:place/mods:placeTerm[not(@authority='marccountry')]
      " />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
