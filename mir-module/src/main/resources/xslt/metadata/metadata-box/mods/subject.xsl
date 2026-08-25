<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:local="http://www.w3.org/2005/xquery-local-functions"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/subject.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/common/ui-helpers.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/name.xsl" />
  <xsl:import href="resource:xslt/utils/mods-utils.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:variable name="subjects" select="metadata/def.modsContainer/modsContainer/mods:mods/mods:subject" />

    <xsl:for-each select="$subjects[
      (count(mods:geographic) &gt; 0 or count(mods:cartographics) &gt; 0)
      and (count(mods:geographic) + count(mods:cartographics)) = count(mods:*)
    ]">
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

    <xsl:variable name="normal-subjects" select="$subjects[not(
      (count(mods:geographic) &gt; 0 or count(mods:cartographics) &gt; 0)
      and (count(mods:geographic) + count(mods:cartographics)) = count(mods:*)
    )]" />
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

  <xsl:template match="mods:geographic" mode="subject">
    <xsl:call-template name="authority-link">
      <xsl:with-param name="content">
        <xsl:value-of select="." />
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
            <i class="fas fa-map-location-dot me-2"> </i>
            <xsl:value-of select="mcri18n:translate('mir.details.popover.type.geographic')" />
          </dd>
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

  <xsl:template match="mods:topic" mode="subject">
    <xsl:call-template name="authority-link">
      <xsl:with-param name="content">
        <xsl:value-of select="." />
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
            <i class="fas fa-tag me-2"> </i>
            <xsl:value-of select="mcri18n:translate('mir.details.popover.type.topic')" />
          </dd>
        </dl>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:name" mode="subject">
    <xsl:call-template name="authority-link">
      <xsl:with-param name="content">
        <xsl:value-of select="local:mods-name-string(.)" />
      </xsl:with-param>
      <xsl:with-param name="href" select="@valueURI" />
    </xsl:call-template>

    <xsl:variable name="name-identifiers">
      <xsl:call-template name="getNameIdentifiers">
        <xsl:with-param name="entity" select="." />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="identifiers" select="$name-identifiers/nameIdentifier" />
    <xsl:variable name="affiliations" select="mods:affiliation/text()" />

    <xsl:call-template name="info">
      <xsl:with-param name="content">
        <dl>
          <dt>
            <xsl:value-of select="mcri18n:translate('mir.details.popover.type')" />
          </dt>
          <dd>
            <xsl:choose>
              <xsl:when test="@type='family'">
                <i class="fas fa-people-roof me-2"> </i>
              </xsl:when>
              <xsl:when test="@type='personal'">
                <i class="fas fa-person me-2"> </i>
              </xsl:when>
              <xsl:when test="@type='corporate'">
                <i class="fas fa-building me-2"> </i>
              </xsl:when>
              <xsl:when test="@type='conference'">
                <i class="fas fa-people-line me-2"> </i>
              </xsl:when>
            </xsl:choose>
            <xsl:value-of select="mcri18n:translate(concat('mir.details.popover.type.', @type))" />
          </dd>
          <xsl:if test="$identifiers">
            <xsl:for-each select="$identifiers">
              <dt>
                <xsl:value-of select="@label" />
              </dt>
              <dd>
                <a href="{@uri}{@id}">
                  <xsl:value-of select="@id" />
                </a>
              </dd>
            </xsl:for-each>
          </xsl:if>
          <xsl:if test="string-length($affiliations) &gt; 0">
            <dt>
              <xsl:value-of select="mcri18n:translate('mir.affiliation')" />
            </dt>
            <dd>
              <xsl:value-of select="$affiliations" />
            </dd>
          </xsl:if>
        </dl>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:titleInfo" mode="subject">
    <xsl:call-template name="authority-link">
      <xsl:with-param name="content">
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
            <i class="fa fa-newspaper me-2"> </i>
            <xsl:value-of select="mcri18n:translate('mir.details.popover.type.titleInfo')" />
          </dd>
        </dl>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
