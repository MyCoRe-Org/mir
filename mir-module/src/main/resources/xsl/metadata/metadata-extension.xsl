<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="fn mods">

  <xsl:import href="xslImport:modsmeta:metadata/metadata-extension.xsl" />

  <xsl:template name="print-field">
    <xsl:param name="i18n" />
    <xsl:param name="pre-value" />
    <xsl:param name="value" />
    <dt>
      <xsl:value-of select="document(concat('i18n:', $i18n))" />
    </dt>
    <dd>
      <xsl:choose>
        <xsl:when test="$pre-value and $value">
          <strong>
            <xsl:value-of select="$pre-value" />
          </strong>
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:when test="$pre-value">
          <xsl:value-of select="$pre-value" />
        </xsl:when>
      </xsl:choose>
      <xsl:if test="$value">
        <xsl:copy-of select="$value" />
      </xsl:if>
    </dd>
  </xsl:template>

  <xsl:template name="build-link">
    <xsl:param name="url" />
    <xsl:param name="text" select="$url"/>
    <a href="{$url}">
      <xsl:value-of select="$text" />
    </a>
  </xsl:template>

  <xsl:template name="concat">
    <xsl:param name="input" />
    <xsl:for-each select="$input">
      <xsl:copy-of select="."/>
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
      <div id="metadata-extension">
        <div class="mir_metadata" style="margin-top:-30px;">
          <hr class="my-3" />
          <dl>
            <xsl:if test="$mods/mods:extension[@displayLabel='codemeta-part']/fn:map">
              <xsl:call-template name="codemeta">
                <xsl:with-param name="codemeta" select="$mods/mods:extension[@displayLabel='codemeta-part']/fn:map" />
              </xsl:call-template>
            </xsl:if>
            <xsl:if test="$mods/mods:extension[@displayLabel='advanced-part']/fn:map">
              <xsl:call-template name="advanced">
                <xsl:with-param name="advanced" select="$mods/mods:extension[@displayLabel='advanced-part']/fn:map" />
              </xsl:call-template>
            </xsl:if>
          </dl>
        </div>
      </div>
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template name="get-classification-label">
    <xsl:param name="classification" />
    <xsl:value-of select="document(concat('classification:metadata:0:children:', $classification))//category/label[@xml:lang=$CurrentLang]/@text" />
  </xsl:template>

  <xsl:template name="advanced">
    <xsl:param name="advanced" />
    <xsl:if test="$advanced/fn:array[@key='type']/fn:map">
      <xsl:call-template name="print-field">
        <xsl:with-param name="i18n" select="'mir.advanced.type'" />
        <xsl:with-param name="pre-value">
          <xsl:call-template name="get-classification-label">
            <xsl:with-param name="classification" select="$advanced/fn:array[@key='type']/fn:map/fn:string[@key='type']" />
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="value" select="$advanced/fn:array[@key='type']/fn:map/fn:string[@key='description']" />
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$advanced/fn:array[@key='researchObject']/fn:map">
      <xsl:call-template name="print-field">
        <xsl:with-param name="i18n" select="'mir.advanced.researchObject'" />
        <xsl:with-param name="pre-value">
          <xsl:call-template name="get-classification-label">
            <xsl:with-param name="classification" select="$advanced/fn:array[@key='researchObject']/fn:map/fn:string[@key='type']" />
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="value" select="$advanced/fn:array[@key='researchObject']/fn:map/fn:string[@key='description']" />
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$advanced/fn:array[@key='dataOrigin']/fn:map">
      <xsl:call-template name="print-field">
        <xsl:with-param name="i18n" select="'mir.advanced.dataOrigin'" />
        <xsl:with-param name="pre-value">
          <xsl:call-template name="get-classification-label">
            <xsl:with-param name="classification" select="$advanced/fn:array[@key='dataOrigin']/fn:map/fn:string[@key='type']" />
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="value" select="$advanced/fn:array[@key='dataOrigin']/fn:map/fn:string[@key='description']" />
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$advanced/fn:array[@key='software_types']/fn:map">
      <xsl:variable name="name" select="$advanced/fn:array[@key='software_types']/fn:map/fn:string[@key='name']" />
      <xsl:variable name="version" select="$advanced/fn:array[@key='software_types']/fn:map/fn:string[@key='version']" />
      <xsl:variable name="fullname">
        <xsl:choose>
          <xsl:when test="$version">
            <xsl:value-of select="concat($name, ' (', $version, ')')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$name" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="print-field">
        <xsl:with-param name="i18n" select="'mir.advanced.software'" />
        <xsl:with-param name="pre-value">
          <xsl:call-template name="get-classification-label">
            <xsl:with-param name="classification" select="$advanced/fn:array[@key='software_types']/fn:map/fn:string[@key='type']" />
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="value" select="$fullname" />
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$advanced/fn:string[@key='methods']">
      <xsl:call-template name="print-field">
        <xsl:with-param name="i18n" select="'mir.advanced.methods'" />
        <xsl:with-param name="value" select="$advanced/fn:string[@key='methods']" />
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$advanced/fn:string[@key='instruments']">
      <xsl:call-template name="print-field">
        <xsl:with-param name="i18n" select="'mir.advanced.instruments'" />
        <xsl:with-param name="value" select="$advanced/fn:string[@key='instruments']" />
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$advanced/fn:string[@key='processing']">
      <xsl:call-template name="print-field">
        <xsl:with-param name="i18n" select="'mir.advanced.processing'" />
        <xsl:with-param name="value" select="$advanced/fn:string[@key='processing']" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="fn:string" mode="codemeta">
    <xsl:call-template name="print-field">
      <xsl:with-param name="i18n" select="concat('mir.codeMeta.', @key)" />
      <xsl:with-param name="value" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="fn:array" mode="codemeta">
    <xsl:choose>
      <xsl:when test="fn:map">
        <xsl:call-template name="print-field">
          <xsl:with-param name="i18n" select="concat('mir.codeMeta.', @key)" />
          <xsl:with-param name="value">
            <xsl:call-template name="concat">
              <xsl:with-param name="input" select="fn:map/fn:string[@key='@value']" />
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="print-field">
          <xsl:with-param name="i18n" select="concat('mir.codeMeta.', @key)" />
          <xsl:with-param name="value">
            <xsl:call-template name="concat">
              <xsl:with-param name="input" select="fn:string" />
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="fn:string[@key='codeRepository' or @key='buildInstructions' or @key='releaseNotes' or @key='readme' or @key='issueTracker' or @key='contIntegration']" mode="codemeta">
    <xsl:call-template name="print-field">
      <xsl:with-param name="i18n" select="concat('mir.codeMeta.', @key)" />
      <xsl:with-param name="value">
        <xsl:call-template name="build-link">
          <xsl:with-param name="url" select="." />
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="fn:array[@key='softwareRequirements' or @key='softwareSuggestions']" mode="codemeta">
    <xsl:variable name="links">
      <xsl:for-each select="fn:map">
        <xsl:choose>
          <xsl:when test="fn:string[@key='name'] and fn:string[@key='codeRepository']">
            <xsl:call-template name="build-link">
              <xsl:with-param name="url" select="fn:string[@key='codeRepository']" />
              <xsl:with-param name="text" select="fn:string[@key='name']" />
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="fn:string[@key='codeRepository']">
            <xsl:call-template name="build-link">
              <xsl:with-param name="url" select="fn:string[@key='codeRepository']" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="fn:string[@key='name']" />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="position() != last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="print-field">
      <xsl:with-param name="i18n" select="concat('mir.codeMeta.', @key)" />
      <xsl:with-param name="value" select="$links" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="codemeta">
    <xsl:param name="codemeta" />
    <xsl:if test="$codemeta/fn:map[@key='developmentStatus']">
      <xsl:variable name="status" select="$codemeta/fn:map[@key='developmentStatus']/fn:string[@key='@value']" />
      <xsl:call-template name="print-field">
        <xsl:with-param name="i18n" select="'mir.codeMeta.developmentStatus'" />
        <xsl:with-param name="value">
          <xsl:call-template name="get-classification-label">
            <xsl:with-param name="classification" select="$status" />
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$codemeta/fn:string[@key='version']">
      <xsl:apply-templates select="$codemeta/fn:string[@key='version']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:array[@key='applicationCategory']">
      <xsl:apply-templates select="$codemeta/fn:array[@key='applicationCategory']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:array[@key='applicationSubCategory']">
      <xsl:apply-templates select="$codemeta/fn:array[@key='applicationSubCategory']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:array[@key='programmingLanguage']">
      <xsl:call-template name="print-field">
        <xsl:with-param name="i18n" select="'mir.codeMeta.programmingLanguage'" />
        <xsl:with-param name="value">
          <xsl:call-template name="concat">
            <xsl:with-param name="input" select="$codemeta/fn:array[@key='programmingLanguage']/fn:map/fn:string[@key='name']" />
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$codemeta/fn:array[@key='operatingSystem']">
      <xsl:apply-templates select="$codemeta/fn:array[@key='operatingSystem']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:array[@key='processorRequirements']">
      <xsl:apply-templates select="$codemeta/fn:array[@key='processorRequirements']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:array[@key='memoryRequirements']">
      <xsl:apply-templates select="$codemeta/fn:array[@key='memoryRequirements']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:array[@key='storageRequirements']">
      <xsl:apply-templates select="$codemeta/fn:array[@key='storageRequirements']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:array[@key='runtimePlatform']">
      <xsl:apply-templates select="$codemeta/fn:array[@key='runtimePlatform']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:array[@key='softwareRequirements']">
      <xsl:apply-templates select="$codemeta/fn:array[@key='softwareRequirements']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:array[@key='softwareSuggestions']">
      <xsl:apply-templates select="$codemeta/fn:array[@key='softwareSuggestions']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:array[@key='permissions']">
      <xsl:apply-templates select="$codemeta/fn:array[@key='permissions']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:string[@key='codeRepository']">
      <xsl:apply-templates select="$codemeta/fn:string[@key='codeRepository']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:string[@key='buildInstructions']">
      <xsl:apply-templates select="$codemeta/fn:string[@key='buildInstructions']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:string[@key='releaseNotes']">
      <xsl:apply-templates select="$codemeta/fn:string[@key='releaseNotes']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:string[@key='contIntegration']">
      <xsl:apply-templates select="$codemeta/fn:string[@key='contIntegration']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:string[@key='issueTracker']">
      <xsl:apply-templates select="$codemeta/fn:string[@key='issueTracker']" mode="codemeta" />
    </xsl:if>
    <xsl:if test="$codemeta/fn:string[@key='readme']">
      <xsl:apply-templates select="$codemeta/fn:string[@key='readme']" mode="codemeta" />
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
