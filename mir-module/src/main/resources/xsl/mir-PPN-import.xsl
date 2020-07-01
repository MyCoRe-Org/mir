<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mirrelateditemfinder="xalan://org.mycore.mir.impexp.MIRRelatedItemFinder"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:str="http://exslt.org/strings"
  exclude-result-prefixes="xlink mirrelateditemfinder">
  <xsl:param name="MIR.projectid.default"/>
  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:relatedItem[not(@xlink:href)]">
    <xsl:choose>
      <xsl:when test="mods:titleInfo/mods:title or mods:identifier">
        <xsl:variable name="mcrid" select="mirrelateditemfinder:findRelatedItem(node())"/>
        <xsl:choose>
          <xsl:when test="string-length($mcrid) &gt; 0">
            <xsl:copy>
              <xsl:attribute name="xlink:href"><xsl:value-of select="$mcrid"/></xsl:attribute>
              <xsl:apply-templates select="@*|node()" />
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy>
              <xsl:attribute name="xlink:href"><xsl:value-of select="concat($MIR.projectid.default,'_mods_00000000')"/></xsl:attribute>
              <xsl:apply-templates select="@*|node()" />
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Remove originInfo without eventType. Copy if not originInfo without @eventType='publication' is present.-->
  <xsl:template match="mods:originInfo[not(@eventType)]">
    <xsl:if test="not(//mods:mods/mods:originInfo/@eventType='publication')">
      <mods:originInfo eventType="publication">
        <xsl:apply-templates select="node()|@*" />
      </mods:originInfo>
    </xsl:if>
  </xsl:template>
  
  <!-- Special Case for old unapi mods. Copy edition.-->
  <xsl:template match="mods:originInfo[@eventType='publication']">
    <mods:originInfo>
      <xsl:apply-templates select="node()|@*" />
      <xsl:if test="not(mods:edition) and ../mods:originInfo[not(@eventType)]/mods:edition">
        <xsl:apply-templates select="../mods:originInfo[not(@eventType)]/mods:edition" />
      </xsl:if>
    </mods:originInfo>
  </xsl:template> 
  
  <xsl:template match="mods:dateIssued[@encoding='marc'][not(../mods:dateIssued[not(@encoding)])]">
    <mods:dateIssued encoding="marc">
      <xsl:value-of select="."/>
    </mods:dateIssued>
    <mods:dateIssued encoding="w3cdtf">
      <xsl:value-of select="."/>
    </mods:dateIssued>
  </xsl:template>

  <xsl:template match="mods:languageTerm[@authority='iso639-2b' and not(../mods:languageTerm[@authority='rfc5646'])]">
    <xsl:variable name="languages" select="document('classification:metadata:-1:children:rfc5646')" />
    <xsl:variable name="biblCode" select="." />
    <xsl:variable name="rfcCode">
      <xsl:value-of select="$languages//category[label[@xml:lang='x-bibl']/@text = $biblCode]/@ID" />
    </xsl:variable>
    <mods:languageTerm authority="rfc5646" type="code">
      <xsl:value-of select="$rfcCode"/>    
    </mods:languageTerm>
  </xsl:template>
  
  <xsl:template match="mods:number">
    <mods:number>
      <xsl:variable name="number">
        <xsl:for-each select="str:tokenize(.,';')">
          <xsl:choose>
            <xsl:when test="contains(.,'Band')">
              <xsl:value-of select="substring-after(.,'Band')"/>
            </xsl:when>
            <xsl:when test="contains(.,'Bd.')">
              <xsl:value-of select="substring-after(.,'Bd.')"/>
            </xsl:when>
            <xsl:when test="contains(.,'Teil')">
              <xsl:value-of select="substring-after(.,'Teil')"/>
            </xsl:when>
            <xsl:when test="contains(.,'Vol.')">
              <xsl:value-of select="substring-after(.,'Vol.')"/>
            </xsl:when>
            <xsl:when test="contains(.,'Vol')">
              <xsl:value-of select="substring-after(.,'Vol')"/>
            </xsl:when>
            <xsl:when test="contains(.,'vol.')">
              <xsl:value-of select="substring-after(.,'Vol.')"/>
            </xsl:when>
            <xsl:when test="contains(.,'vol')">
              <xsl:value-of select="substring-after(.,'Vol')"/>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="string-length($number) &gt; 0">
          <xsl:value-of select="$number"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </mods:number>
  </xsl:template>  
  
  <xsl:template match="mods:start[contains(.,'-')]">
    <mods:start><xsl:value-of select="substring-before(.,'-')"/></mods:start>
    <mods:end><xsl:value-of select="substring-after(.,'-')"/></mods:end>
  </xsl:template>
  
  <xsl:template match="mods:roleTerm[@authority='marcrelator'][@type='code'][text()='edit']">
    <roleTerm authority="marcrelator" type="code">edt</roleTerm>
  </xsl:template>
  
</xsl:stylesheet>