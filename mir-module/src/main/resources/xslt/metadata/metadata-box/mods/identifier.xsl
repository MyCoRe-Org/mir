<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:metadatabox:metadata/metadata-box/mods/identifier.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/metadata-row.xsl" />

  <xsl:template mode="display-metadata" match="mycoreobject">
    <xsl:apply-imports />

    <xsl:variable name="identifiers" select="metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier" />
    <xsl:variable name="identifier-categories" select="
      document('classification:metadata:-1:children:identifier')/mycoreclass/categories"
    />
    <xsl:for-each select="$identifier-categories//category[@ID != 'intern' and @ID != 'issn']">
      <xsl:apply-templates mode="identifier" select="$identifiers[@type = @ID]" />
    </xsl:for-each>
    <xsl:for-each select="$identifiers[@type='issn']">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label" select="mcri18n:translate('mir.identifier.issn')" />
        <xsl:with-param name="value" select="text()" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='hdl']" mode="identifier">
    <xsl:call-template name="meta-row">
      <xsl:with-param name="label" select="mcri18n:translate('component.mods.metaData.dictionary.identifier.hdl')" />
      <xsl:with-param name="value">
        <xsl:variable name="hdl" select="." />
        <a href="{mcrproperty:get('MCR.Handle.Resolver.MasterURL')}{$hdl}">
          <xsl:value-of select="$hdl" />
        </a>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:identifier" mode="identifier">
    <xsl:variable name="identifier" select="document('classification:metadata:-1:children:identifier')" />
    <xsl:variable name="type" select="./@type" />
    <xsl:call-template name="meta-row">
      <xsl:with-param name="label">
        <xsl:choose>
          <xsl:when test="not($identifier//category[@ID=$type])">
            <xsl:value-of select="mcri18n:translate-with-params('component.mods.metaData.dictionary.identifier.other', $type)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$identifier//category[@ID=$type]/label[lang($CurrentLang)]/@text" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="value" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='intern_old']" mode="identifier">
    <xsl:if test="not(mcracl:is-current-user-in-role('guest'))">
      <xsl:call-template name="meta-row">
        <xsl:with-param name="label" select="mcri18n:translate(concat('component.mods.metaData.dictionary.identifier.',@type))" />
        <xsl:with-param name="value" select="." />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='uri' or @type='doi' or @type='urn' or @type='zdbid']" mode="identifier">
    <xsl:call-template name="meta-row">
      <xsl:with-param name="label">
        <xsl:choose>
          <xsl:when test="contains(.,'ppn') or contains(.,'PPN')">
            <xsl:value-of select="mcri18n:translate('component.mods.metaData.dictionary.identifier.ppn')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mcri18n:translate(concat('component.mods.metaData.dictionary.identifier.',@type))" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="value">
        <xsl:variable name="link" select="." />
        <xsl:choose>
          <xsl:when test="contains($link,'ppn') or contains($link,'PPN')">
            <a class="ppn">
              <xsl:attribute name="href">
                <xsl:choose>
                  <xsl:when test="contains($link, 'uri.gbv.de/')"><xsl:value-of select="concat($link, '?format=redirect')"/></xsl:when>
                  <xsl:otherwise><xsl:value-of select="$link"/></xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="contains($link, 'PPN=')">
                  <xsl:value-of select="substring-after($link, 'PPN=')" />
                </xsl:when>
                <xsl:when test="contains($link, ':ppn:')">
                  <xsl:value-of select="substring-after($link, ':ppn:')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$link"/>
                </xsl:otherwise>
              </xsl:choose>
            </a>
          </xsl:when>
          <xsl:when test="@type='doi' and not(contains($link,'http'))">
            <a href="{mcrproperty:get('MCR.DOI.Resolver.MasterURL')}{$link}">
              <xsl:value-of select="$link" />
            </a>
          </xsl:when>
          <xsl:when test="@type='urn' and not(contains($link,'http'))">
            <a href="https://nbn-resolving.org/{$link}">
              <xsl:value-of select="$link" />
            </a>
          </xsl:when>
          <xsl:when test="@type='zdbid' and not(contains($link,'http'))">
            <a href="https://ld.zdb-services.de/resource/{$link}">
              <xsl:value-of select="$link" />
            </a>
          </xsl:when>
          <xsl:otherwise>
            <a href="{$link}">
              <xsl:value-of select="$link" />
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='scopus']" mode="identifier">
    <xsl:call-template name="meta-row">
      <xsl:with-param name="label" select="mcri18n:translate('component.mods.metaData.dictionary.identifier.scopus')" />
      <xsl:with-param name="value">
        <xsl:variable name="scopus" select="." />
        <a href="{mcrproperty:get('MCR.Scopus.Backlink')}{$scopus}">
          <xsl:value-of select="$scopus" />
        </a>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
