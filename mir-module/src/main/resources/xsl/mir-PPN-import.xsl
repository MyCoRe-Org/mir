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

  <xsl:template match="mods:mods">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
      <mods:identifier invalid="yes" type="uri">
        <xsl:value-of select="concat('//gso.gbv.de/DB=2.1/PPNSET?PPN=', //mods:mods/mods:recordInfo/mods:recordIdentifier[@source='DE-627'])" />
      </mods:identifier>
    </xsl:copy>
  </xsl:template>

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
            <xsl:if test="mods:titleInfo/mods:title">
              <xsl:choose>
                <xsl:when test="@type='host' or @type='series' ">
                  <xsl:copy>
                    <xsl:attribute name="xlink:href"><xsl:value-of select="concat($MIR.projectid.default,'_mods_00000000')"/></xsl:attribute>
                    <xsl:apply-templates select="@*|node()" />
                  </xsl:copy>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="." />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- delete relatedItem without title or ID -->

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
  
  <xsl:template match="mods:nameIdentifier[not(starts-with(.,'(DE-588)'))]">
  </xsl:template>
  
  <xsl:template match="mods:nameIdentifier[starts-with(.,'(DE-588)')]">
    <xsl:variable name="gnd" select="substring-after(.,'(DE-588)')"/>
    <xsl:if test="not(../mods:nameIdentifier[@type='gnd'][text()=$gnd])">
      <mods:nameIdentifier type="gnd">
        <xsl:value-of select="$gnd" />
      </mods:nameIdentifier>
    </xsl:if>
  </xsl:template>
  
  <!-- The Classification wasted the mods. In Future the Basisklassifikation (authority="bkl") could be usefull. -->
  <xsl:template match="mods:classification">
  </xsl:template>
  
  <!-- Names as subjects (Persons, Corporates) didn't editable in the Editor so they removed -->
  <xsl:template match="mods:subject[count(./*[name()='mods:name']) &gt; 0]">
  </xsl:template>
  
  <!-- remove invalid mods -->
  <xsl:template match="mods:extent[text()]">
  </xsl:template>
  
  <xsl:template name="number2isbn_registrant">
    <xsl:param name="rest_isbn" />
    <xsl:variable name="testsegment_registrant" select="substring($rest_isbn,1,5)" />
    <xsl:variable name="isbn_length" select="string-length($rest_isbn)" />
    <xsl:variable name="registrant_length">
      <xsl:choose>
        <xsl:when test="00000 &lt; $testsegment_registrant and $testsegment_registrant &lt; 19999">
          <xsl:value-of select="2" />
        </xsl:when>
        <xsl:when test="20000 &lt; $testsegment_registrant and $testsegment_registrant &lt; 69999">
          <xsl:value-of select="3" />
        </xsl:when>
        <xsl:when test="70000 &lt; $testsegment_registrant and $testsegment_registrant &lt; 84999">
          <xsl:value-of select="4" />
        </xsl:when>
        <xsl:when test="85000 &lt; $testsegment_registrant and $testsegment_registrant &lt; 89999">
          <xsl:value-of select="5" />
        </xsl:when>
        <xsl:when test="90000 &lt; $testsegment_registrant and $testsegment_registrant &lt; 94999">
          <xsl:value-of select="6" />
        </xsl:when>
        <xsl:when test="95000 &lt; $testsegment_registrant and $testsegment_registrant &lt; 99999">
          <xsl:value-of select="7" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of
      select="concat(substring($rest_isbn,1,$registrant_length),'-',substring($rest_isbn,$registrant_length + 1,$isbn_length - $registrant_length - 1),'-',substring($rest_isbn,$isbn_length,1))" />
  </xsl:template>

  <xsl:template name="number2isbn">
    <xsl:param name="isbn" />
    <xsl:variable name="testsegment_reggroup" select="substring($isbn,1,5)" />
    <xsl:choose>
      <xsl:when test="00000 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 59999">
        <xsl:value-of select="concat(substring($isbn,1,1),'-')" />
        <xsl:call-template name="number2isbn_registrant">
          <xsl:with-param name="rest_isbn" select="substring($isbn,2)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="60000 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 69999">
        <xsl:value-of select="$isbn" />
      </xsl:when>
      <xsl:when test="70000 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 79999">
        <xsl:value-of select="concat(substring($isbn,1,1),'-')" />
        <xsl:call-template name="number2isbn_registrant">
          <xsl:with-param name="rest_isbn" select="substring($isbn,2)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="80000 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 94999">
        <xsl:value-of select="concat(substring($isbn,1,2),'-')" />
        <xsl:call-template name="number2isbn_registrant">
          <xsl:with-param name="rest_isbn" select="substring($isbn,3)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="95000 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 98999">
        <xsl:value-of select="concat(substring($isbn,1,3),'-')" />
        <xsl:call-template name="number2isbn_registrant">
          <xsl:with-param name="rest_isbn" select="substring($isbn,4)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="99000 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 99899">
        <xsl:value-of select="concat(substring($isbn,1,4),'-')" />
        <xsl:call-template name="number2isbn_registrant">
          <xsl:with-param name="rest_isbn" select="substring($isbn,5)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="99900 &lt; $testsegment_reggroup and $testsegment_reggroup &lt; 99999">
        <xsl:value-of select="concat(substring($isbn,1,5),'-')" />
        <xsl:call-template name="number2isbn_registrant">
          <xsl:with-param name="rest_isbn" select="substring($isbn,6)" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$isbn" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mods:identifier[@type='isbn']">
     <mods:identifier type="isbn"> 
        <xsl:choose>
          <xsl:when test="translate(., '1234567890', '----------') = '----------'">
            <xsl:call-template name="number2isbn">
              <xsl:with-param name="isbn" select="." />
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="translate(., '1234567890', '----------') = '-------------'">
            <xsl:value-of select="concat(substring(.,1,3),'-')" />
            <xsl:call-template name="number2isbn">
              <xsl:with-param name="isbn" select="substring(.,4)" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </mods:identifier>
  </xsl:template>  
  
</xsl:stylesheet>