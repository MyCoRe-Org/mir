<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport" exclude-result-prefixes="mcrmods" version="1.0"
>

  <xsl:include href="copynodes.xsl" />

  <!-- put value string (after authority URI) in attribute valueURIxEditor -->
  <xsl:template match="@valueURI">
        <xsl:attribute name="valueURIxEditor">
          <xsl:value-of select="substring-after(.,'#')" />
        </xsl:attribute>
  </xsl:template>

  <!-- A single page (edited as start=end) is represented as mods:detail/@type='page' -->
  <xsl:template match="mods:detail[@type='page']">
    <mods:extent unit="pages">
      <mods:start>
        <xsl:value-of select="mods:number" />
      </mods:start>
      <mods:end>
        <xsl:value-of select="mods:number" />
      </mods:end>
    </mods:extent>
  </xsl:template>

  <!-- Derive dateIssued from dateOther if not present -->
  <xsl:template match="mods:dateOther[(@type='accepted') and not(../mods:dateIssued)]">
    <mods:dateIssued>
      <xsl:copy-of select="@encoding" />
      <xsl:value-of select="substring(.,1,4)" />
    </mods:dateIssued>
    <xsl:copy-of select="." />
  </xsl:template>

  <xsl:template match="mods:name[@type='personal']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:if test="mods:namePart[@type='family'] and mods:namePart[@type='given']">
        <mods:displayForm>
          <xsl:value-of select="concat(mods:namePart[@type='family'],', ',mods:namePart[@type='given'])" />
        </mods:displayForm>
      </xsl:if>
      <xsl:apply-templates select="*" />
      <xsl:if test="not(mods:role/mods:roleTerm)">
        <mods:role>
          <mods:roleTerm authority="marcrelator" type="code">aut</mods:roleTerm>
        </mods:role>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Remove this mods:classification entry, will be created again while saving using mods:accessCondtition (see MIR-161) -->
  <xsl:template match="mods:classification[@authority='accessRestriction']">
    <!-- do nothing -->
  </xsl:template>

  <xsl:template match="mods:identifier[@type='open-aire']">
    <mods:openAireID>
      <xsl:value-of select="." />
    </mods:openAireID>
  </xsl:template>

  <!-- to @categId -->
  <xsl:template match="mods:classification[@generator='user selected']">
    <xsl:copy>
      <xsl:variable name="classNodes" select="mcrmods:getMCRClassNodes(.)" />
      <xsl:apply-templates select="$classNodes/@*|@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:typeOfResource">
    <xsl:copy>
      <xsl:variable name="classNodes" select="mcrmods:getMCRClassNodes(.)" />
      <xsl:apply-templates select="$classNodes/@*|@*" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:languageTerm[@authority='iso639-2b']">
    <xsl:variable name="classNodes" select="mcrmods:convertIsoToRfc(.)" />
    <xsl:if test="not(preceding-sibling::mods:languageTerm[@authority='rfc4646']/text() = $classNodes/text())">
      <xsl:if test="not(following-sibling::mods:languageTerm[@authority='rfc4646']/text() = $classNodes/text())">
        <xsl:apply-templates select="$classNodes" />
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:accessCondition[@type='restriction on access']">
    <mods:accessCondition type="restriction on access" xlink:href='http://www.mycore.org/classifications/mir_access'>
      <xsl:value-of select="substring-after(@xlink:href, '#')" />
    </mods:accessCondition>
  </xsl:template>

  <xsl:template match="mods:name/mods:etal">
    <mods:displayForm>et.al.</mods:displayForm>
  </xsl:template>

</xsl:stylesheet>