<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.w3.org/2005/xquery-local-functions"
  xmlns:mirdateconverter="http://www.mycore.de/xslt/mirdateconverter"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/dates.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:variable name="origin-infos" select="metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo" />
    <xsl:apply-templates mode="date" select="$origin-infos[@eventType='creation']/mods:dateCreated" />
    <xsl:apply-templates mode="date" select="$origin-infos[@eventType='creation']/mods:dateOther[@type='submitted']">
      <xsl:with-param name="label" select="mcri18n:translate('component.mods.metaData.dictionary.dateSubmitted')" />
    </xsl:apply-templates>
    <xsl:apply-templates mode="date" select="$origin-infos[@eventType='creation']/mods:dateOther[@type='accepted']">
      <xsl:with-param name="label" select="mcri18n:translate('component.mods.metaData.dictionary.dateAccepted')" />
    </xsl:apply-templates>
    <xsl:apply-templates mode="date" select="$origin-infos[@eventType='review']/mods:dateOther[@type='reviewed']">
      <xsl:with-param name="label" select="mcri18n:translate('component.mods.metaData.dictionary.dateReviewed')" />
    </xsl:apply-templates>
    <xsl:apply-templates mode="date" select="$origin-infos[@eventType='collection']/mods:dateCaptured" />
    <xsl:apply-templates mode="date" select="
      $origin-infos[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']
    " />
    <xsl:apply-templates mode="date" select="$origin-infos[@eventType='update']/mods:dateModified" />
  </xsl:template>

  <xsl:template mode="date" match="mods:dateCreated|mods:dateOther|mods:dateIssued|mods:dateCaptured|mods:dateModified">
    <xsl:param name="label" select="mcri18n:translate(local:date-label-key(.))" />

    <xsl:if test="not(@point='end' and (
      preceding-sibling::*[name(current())=name()][@point='start']
      or following-sibling::*[name(current())=name()][@point='start']
    ))">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label" select="$label" />
        <xsl:with-param name="value">
          <xsl:if test="local-name()='dateIssued'">
            <meta property="datePublished">
              <xsl:attribute name="content">
                <xsl:value-of select="." />
              </xsl:attribute>
            </meta>
          </xsl:if>
          <xsl:value-of select="local:range-date-display(.)" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:function name="local:date-label-key" as="xs:string">
    <xsl:param name="node" as="element()" />

    <xsl:variable name="range-key" select="concat('component.mods.metaData.dictionary.', local-name($node), '.range')" />
    <xsl:sequence select="
      if (($node/@point='start' or $node/@point='end') and mcri18n:exists($range-key))
      then $range-key
      else concat('component.mods.metaData.dictionary.', local-name($node))
    " />
  </xsl:function>

  <xsl:function name="local:range-partner" as="element()*">
    <xsl:param name="node" as="element()" />
    <xsl:param name="point" as="xs:string" />

    <xsl:variable name="type-filter" select="if ($node/self::mods:dateOther) then $node/@type else ()" />

    <xsl:sequence select="
      $node/preceding-sibling::*[name($node)=name()][@point=$point][not($type-filter) or @type=$type-filter]
      | $node/following-sibling::*[name($node)=name()][@point=$point][not($type-filter) or @type=$type-filter]
    " />
  </xsl:function>

  <xsl:function name="local:range-date-display" as="xs:string">
    <xsl:param name="node" as="element()" />

    <xsl:variable name="end-partner" select="local:range-partner($node, 'end')[1]" />
    <xsl:variable name="start-partner" select="local:range-partner($node, 'start')[1]" />

    <xsl:sequence select="
      if ($node/@point='start' and $end-partner)
      then local:normalize-date-display($node) || ' - ' || local:normalize-date-display($end-partner)
      else if ($node/@point='start' and not($end-partner))
      then local:normalize-date-display($node) || ' - '
      else if ($node/@point='end' and not($start-partner))
      then ' - ' || local:normalize-date-display($node)
      else local:normalize-date-display($node)
    " />
  </xsl:function>

  <xsl:function name="local:normalize-date-display" as="xs:string">
    <xsl:param name="node" as="element()" />

    <xsl:variable name="normalized" select="mirdateconverter:convert-date($node, 'ISO8601')" />

    <xsl:sequence select="
      if (matches($normalized, '^\d{4}$'))
      then $normalized
      else if (matches($normalized, '^\d{4}-\d{2}$'))
      then format-date(xs:date($normalized), mcri18n:translate('mir.xsl3.formate.yearMonth'))
      else if (matches($normalized, '^\d{4}-\d{2}-\d{2}$'))
      then format-date(xs:date($normalized), mcri18n:translate('mir.xsl3.formate.date'))
      else $normalized
    " />
  </xsl:function>

</xsl:stylesheet>
