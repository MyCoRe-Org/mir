<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrclass="http://www.mycore.de/xslt/classification"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='physical-description.form']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:variable name="file-type-class" select="
      document('classification:metadata:-1:children:mir_filetype')/mycoreclass
    " />
    <xsl:variable name="form" select="$mods/mods:physicalDescription/mods:form[
      @type = 'file' and @authorityURI = $file-type-class/label[@xml:lang = 'x-uri']/@text
    ][1]" />
    <xsl:if test="$form">
      <xsl:variable name="category" select="
        $file-type-class/categories//category[@ID = substring-after($form/@valueURI, '#')]
      " />
      <xsl:if test="$category">
        <xsl:call-template name="meta-row">
          <xsl:with-param name="label-key" select="'mir.physical.description.form'" />
          <xsl:with-param name="value" select="mcrclass:current-label-text($category)" />
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="field[@name='physical-description.note']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="label-key" select="'mir.physical.description.note'" />
      <xsl:with-param name="nodes" select="$mods/mods:physicalDescription/mods:note[@xlink:type = 'simple'][1]" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="field[@name='physical-description']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:for-each select="$mods/mods:physicalDescription/mods:extent">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.extent'" />
        <xsl:with-param name="value">
          <xsl:call-template name="format-extent" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
