<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="http://www.mycore.org/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport" exclude-result-prefixes="mcrmods xlink mcr" version="1.0"
>

  <xsl:include href="copynodes.xsl" />

  <!-- create value URI using valueURIxEditor and authorityURI -->
  <xsl:template match="@valueURIxEditor">
        <xsl:choose>
          <xsl:when test="starts-with(., 'http://d-nb.info/gnd/')">
            <mods:nameIdentifier type="gnd" typeURI="http://d-nb.info/gnd/"><xsl:value-of select="substring-after(., 'http://d-nb.info/gnd/')" /></mods:nameIdentifier>
          </xsl:when>
          <xsl:when test="starts-with(., 'http://www.viaf.org/')">
            <mods:nameIdentifier type="viaf" typeURI="http://www.viaf.org/"><xsl:value-of select="substring-after(., 'http://www.viaf.org/')" /></mods:nameIdentifier>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="valueURI">
              <xsl:value-of select="concat(../@authorityURI,'#',.)" />
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:nameIdentifier[@type=preceding-sibling::mods:nameIdentifier/@type or contains(../@valueURIxEditor, @type)]">
    <xsl:message>
      <xsl:value-of select="concat('Skipping ',@type,' identifier: ',.,' due to previous declaration.')" />
    </xsl:message>
  </xsl:template>

  <xsl:template match="mods:nameIdentifier">
    <xsl:choose>
      <xsl:when test="@type='gnd'">
        <mods:nameIdentifier type="gnd" typeURI="http://d-nb.info/gnd/"><xsl:value-of select="." /></mods:nameIdentifier>
      </xsl:when>
      <xsl:when test="@type='viaf'">
        <mods:nameIdentifier type="viaf" typeURI="http://www.viaf.org/"><xsl:value-of select="." /></mods:nameIdentifier>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- A single page (entered as start=end) must be represented as mods:detail/@type='page' -->
  <xsl:template match="mods:extent[(@unit='pages') and (mods:start=mods:end)]">
    <mods:detail type="page">
      <mods:number>
        <xsl:value-of select="mods:start" />
      </mods:number>
    </mods:detail>
  </xsl:template>

  <!-- Copy content of mods:accessCondtition to mods:classification to enable classification support (see MIR-161) -->
  <xsl:template match="mods:accessCondition[@type='restriction on access'][@xlink:href='http://www.mycore.org/classifications/mir_access']">
    <mods:accessCondition type="restriction on access">
      <xsl:attribute name="xlink:href">
        <xsl:value-of select="concat(@xlink:href, '#', .)" />
      </xsl:attribute>
    </mods:accessCondition>
  </xsl:template>

  <xsl:template match="@mcr:categId" />
  <xsl:template match="*[@mcr:categId]">
    <xsl:copy>
      <xsl:variable name="classNodes" select="mcrmods:getClassNodes(.)" />
      <xsl:apply-templates select='$classNodes/@*|@*|node()|$classNodes/node()' />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:openAireID">
    <mods:identifier type="open-aire">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="mods:name/mods:displayForm">
    <xsl:variable name="etalShortcut">|etal|et al|et.al.|u.a.|ua|etc|u.s.w.|usw|...</xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($etalShortcut,.)">
          <mods:etal/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:originInfo/*[not(self::mods:dateOther)]">
    <xsl:choose>
      <xsl:when test="following-sibling::*[name(current())=name()][@point='end']">
        <xsl:copy>
          <xsl:attribute name="point">start</xsl:attribute>
          <xsl:copy-of select="@*|node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="not(following-sibling::*[name(current())=name()]) and not(preceding-sibling::*[name(current())=name()])">
        <xsl:copy>
          <xsl:apply-templates select="@*[not(name() = 'point')]|node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:originInfo/mods:dateOther">
    <xsl:choose>
      <xsl:when test="following-sibling::mods:dateOther[@type=current()/@type][@point='end']">
        <xsl:copy>
          <xsl:attribute name="point">start</xsl:attribute>
          <xsl:copy-of select="@*|node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="not(following-sibling::mods:dateOther[@type=current()/@type]) and not(preceding-sibling::mods:dateOther[@type=current()/@type])">
        <xsl:copy>
          <xsl:apply-templates select="@*[not(name() = 'point')]|node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>