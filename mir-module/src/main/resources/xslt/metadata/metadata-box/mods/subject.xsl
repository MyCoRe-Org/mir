<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.mycore.de/xslt/mirlocal/metadata-box/mods/subject"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:variable name="local:icons" as="map(xs:string, xs:string)" select="map {
    'geographic': 'fas fa-map-location-dot',
    'topic': 'fas fa-tag',
    'titleInfo': 'fa fa-newspaper',
    'family': 'fas fa-people-roof',
    'personal': 'fas fa-person',
    'corporate': 'fas fa-building',
    'conference': 'fas fa-people-line'
  }" />

  <xsl:mode name="local:text" on-no-match="text-only-copy" />
  <xsl:mode name="local:details" on-no-match="deep-skip" />

  <xsl:template match="field[@name='subject.geographic']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:for-each select="$mods/mods:subject[local:is-geographic-subject(.)]">
      <xsl:call-template name="mods-meta-row">
        <xsl:with-param name="nodes" select="mods:geographic" />
      </xsl:call-template>

      <xsl:variable name="coordinates-label" select="mcri18n:translate('mir.cartographics.coordinates')" />
      <xsl:for-each select="mods:cartographics/mods:coordinates">
        <xsl:call-template name="meta-row">
          <xsl:with-param name="label" select="$coordinates-label" />
          <xsl:with-param name="value">
            <xsl:call-template name="coordinates" />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="field[@name='subject']" mode="metadata-box-field">
    <xsl:param name="object" as="element(mycoreobject)" />
    <xsl:variable name="mods" select="mirobject:mods($object)" />

    <xsl:variable name="normal-subjects" select="$mods/mods:subject[not(local:is-geographic-subject(.))]" />
    <xsl:if test="$normal-subjects">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label-key" select="'component.mods.metaData.dictionary.subject'" />
        <xsl:with-param name="value">
          <xsl:for-each select="$normal-subjects">
            <ol class="topic-list">
              <xsl:for-each select="mods:*">
                <li class="topic-element">
                  <xsl:apply-templates mode="subject" select="." />
                </li>
              </xsl:for-each>
            </ol>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:geographic|mods:topic|mods:name|mods:titleInfo" mode="subject">
    <xsl:variable name="type" select="local:subject-type(.)" />

    <xsl:call-template name="authority-link">
      <xsl:with-param name="content">
        <xsl:apply-templates select="." mode="local:text" />
      </xsl:with-param>
      <xsl:with-param name="href" select="@valueURI" />
    </xsl:call-template>

    <xsl:call-template name="info">
      <xsl:with-param name="content">
        <dl>
          <dt>
            <xsl:value-of select="mcri18n:translate('mir.details.popover.type')" />
          </dt>
          <dd>
            <xsl:if test="map:contains($local:icons, $type)">
              <i class="{$local:icons($type)} me-2"> </i>
            </xsl:if>
            <xsl:value-of select="mcri18n:translate('mir.details.popover.type.' || $type)" />
          </dd>
          <xsl:apply-templates select="." mode="local:details" />
        </dl>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:cartographics" mode="subject">
    <xsl:call-template name="authority-link">
      <xsl:with-param name="content">
        <xsl:call-template name="coordinates" />
      </xsl:with-param>
      <xsl:with-param name="href" select="@valueURI" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:name" mode="local:text">
    <xsl:variable name="name-value">
      <xsl:apply-templates select="." mode="name-value" />
    </xsl:variable>
    <xsl:value-of select="$name-value" />
  </xsl:template>

  <xsl:template match="mods:titleInfo" mode="local:text">
    <xsl:value-of select="mods:title" />
    <xsl:if test="mods:subTitle">
      <xsl:text>: </xsl:text>
      <xsl:value-of select="mods:subTitle" />
    </xsl:if>
    <xsl:if test="mods:partNumber">
      <xsl:text> </xsl:text>
      <xsl:value-of select="mods:partNumber" />
    </xsl:if>
    <xsl:if test="mods:partName">
      <xsl:text> </xsl:text>
      <xsl:value-of select="mods:partName" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:name" mode="local:details">
    <xsl:variable name="name-identifiers">
      <xsl:call-template name="getNameIdentifiers">
        <xsl:with-param name="entity" select="." />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="affiliations" select="mods:affiliation[normalize-space()]" />

    <xsl:for-each select="$name-identifiers/nameIdentifier">
      <dt>
        <xsl:value-of select="@label" />
      </dt>
      <dd>
        <a href="{@uri}{@id}">
          <xsl:value-of select="@id" />
        </a>
      </dd>
    </xsl:for-each>
    <xsl:if test="$affiliations">
      <dt>
        <xsl:value-of select="mcri18n:translate('mir.affiliation')" />
      </dt>
      <dd>
        <xsl:value-of select="$affiliations" separator="; " />
      </dd>
    </xsl:if>
  </xsl:template>

  <xsl:function name="local:subject-type" as="xs:string">
    <xsl:param name="entry" as="element()" />
    <xsl:sequence select="if ($entry/self::mods:name) then string($entry/@type) else local-name($entry)" />
  </xsl:function>

  <xsl:function name="local:is-geographic-subject" as="xs:boolean">
    <xsl:param name="subject" as="element(mods:subject)" />

    <xsl:variable name="geo" select="$subject/(mods:geographic | mods:cartographics)" />
    <xsl:sequence select="exists($geo) and count($geo) = count($subject/mods:*)" />
  </xsl:function>

</xsl:stylesheet>
