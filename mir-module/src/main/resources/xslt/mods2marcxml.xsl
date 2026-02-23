<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:mcrmods="http://www.mycore.de/xslt/mods"
  xmlns:mirmarc="http://www.mycore.de/xslt/mirmarc"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcrmods mirmarc mods xlink xs">

  <!--
    Version 2.0 - 2012/05/11 WS
    Upgraded stylesheet to XSLT 2.0
    Upgraded to MODS 3.4
    MODS v3 to MARC21Slim transformation  	ntra 2/20/04
  -->

  <xsl:include href="MARC21slimUtils.xsl" />
  <xsl:include href="functions/mods.xsl" />

  <xsl:output method="xml" indent="yes" encoding="UTF-8" />

  <xsl:variable name="institutes" select="document('classification:metadata:-1:children:mir_institutes')" />
  <xsl:variable name="marcrelator" select="document('classification:metadata:-1:children:marcrelator')" />
  <xsl:variable name="rfc5646" select="document('classification:metadata:-1:children:rfc5646')" />
  <xsl:param name="DefaultLang" />

  <xsl:function name="mirmarc:titleIndicator" as="xs:integer">
    <xsl:param name="node" as="element()" />
    <xsl:choose>
      <xsl:when test="$node/mods:nonSort">
        <xsl:sequence select="string-length($node/mods:nonSort)+1" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="mods:modsCollection">
    <marc:collection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                     xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
      <xsl:apply-templates />
    </marc:collection>
  </xsl:template>

  <xsl:template match="mods:targetAudience[@authority='marctarget']" mode="ctrl008">
    <xsl:choose>
      <xsl:when test=".='adolescent'">
        <xsl:value-of select="'d'" />
      </xsl:when>
      <xsl:when test=".='adult'">
        <xsl:value-of select="'e'" />
      </xsl:when>
      <xsl:when test=".='general'">
        <xsl:value-of select="'g'" />
      </xsl:when>
      <xsl:when test=".='juvenile'">
        <xsl:value-of select="'j'" />
      </xsl:when>
      <xsl:when test=".='preschool'">
        <xsl:value-of select="'a'" />
      </xsl:when>
      <xsl:when test=".='specialized'">
        <xsl:value-of select="'f'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'|'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:typeOfResource" mode="leader">
    <xsl:choose>
      <xsl:when test="text()='text'">
        <xsl:value-of select="'a'" />
      </xsl:when>
      <xsl:when test="text()='text' and @manuscript='yes'">
        <xsl:value-of select="'t'" />
      </xsl:when>
      <xsl:when test="text()='cartographic' and @manuscript='yes'">
        <xsl:value-of select="'f'" />
      </xsl:when>
      <xsl:when test="text()='cartographic'">
        <xsl:value-of select="'e'" />
      </xsl:when>
      <xsl:when test="text()='notated music' and @manuscript='yes'">
        <xsl:value-of select="'d'" />
      </xsl:when>
      <xsl:when test="text()='notated music'">
        <xsl:value-of select="'c'" />
      </xsl:when>
      <xsl:when test="text()='sound recording-nonmusical'">
        <xsl:value-of select="'i'" />
      </xsl:when>
      <xsl:when test="text()='sound recording'">
        <xsl:value-of select="'j'" />
      </xsl:when>
      <xsl:when test="text()='sound recording-musical'">
        <xsl:value-of select="'j'" />
      </xsl:when>
      <xsl:when test="text()='still image'">
        <xsl:value-of select="'k'" />
      </xsl:when>
      <xsl:when test="text()='moving image'">
        <xsl:value-of select="'g'" />
      </xsl:when>
      <xsl:when test="text()='three dimensional object'">
        <xsl:value-of select="'r'" />
      </xsl:when>
      <xsl:when test="text()='software, multimedia'">
        <xsl:value-of select="'m'" />
      </xsl:when>
      <xsl:when test="text()='mixed material'">
        <xsl:value-of select="'p'" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:typeOfResource" mode="ctrl008">
    <xsl:choose>
      <xsl:when test="text()='text' and @manuscript='yes'">
        <xsl:value-of select="'BK'" />
      </xsl:when>
      <xsl:when test="text()='text'">
        <xsl:choose>
          <xsl:when test="../mods:originInfo/mods:issuance='monographic'">
            <xsl:value-of select="'BK'" />
          </xsl:when>
          <xsl:when test="../mods:originInfo/mods:issuance='continuing'">
            <xsl:value-of select="'SE'" />
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="text()='cartographic' and @manuscript='yes'">
        <xsl:value-of select="'MP'" />
      </xsl:when>
      <xsl:when test="text()='cartographic'">
        <xsl:value-of select="'MP'" />
      </xsl:when>
      <xsl:when test="text()='notated music' and @manuscript='yes'">
        <xsl:value-of select="'MU'" />
      </xsl:when>
      <xsl:when test="text()='notated music'">
        <xsl:value-of select="'MU'" />
      </xsl:when>
      <xsl:when test="text()='sound recording'">
        <xsl:value-of select="'MU'" />
      </xsl:when>
      <xsl:when test="text()='sound recording-nonmusical'">
        <xsl:value-of select="'MU'" />
      </xsl:when>
      <xsl:when test="text()='sound recording-musical'">
        <xsl:value-of select="'MU'" />
      </xsl:when>
      <xsl:when test="text()='still image'">
        <xsl:value-of select="'VM'" />
      </xsl:when>
      <xsl:when test="text()='moving image'">
        <xsl:value-of select="'VM'" />
      </xsl:when>
      <xsl:when test="text()='three dimensional object'">
        <xsl:value-of select="'VM'" />
      </xsl:when>
      <xsl:when test="text()='software, multimedia'">
        <xsl:value-of select="'CF'" />
      </xsl:when>
      <xsl:when test="text()='mixed material'">
        <xsl:value-of select="'MM'" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:mods">
    <marc:record>
      <marc:leader>
        <!-- 00-04 -->
        <xsl:value-of select="'     '" />
        <!-- 05 -->
        <xsl:value-of select="'n'" />
        <!-- 06 -->
        <xsl:apply-templates mode="leader" select="mods:typeOfResource[1]" />
        <!-- 07 -->
        <xsl:choose>
          <xsl:when test="mods:originInfo/mods:issuance='monographic'">
            <xsl:value-of select="'m'" />
          </xsl:when>
          <xsl:when test="mods:originInfo/mods:issuance='continuing'">
            <xsl:value-of select="'s'" />
          </xsl:when>
          <xsl:when test="mods:typeOfResource/@collection='yes'">
            <xsl:value-of select="'c'" />
          </xsl:when>
          <xsl:when test="mods:originInfo/mods:issuance='multipart monograph'">
            <xsl:value-of select="'m'" />
          </xsl:when>
          <xsl:when test="mods:originInfo/mods:issuance='single unit'">
            <xsl:value-of select="'m'" />
          </xsl:when>
          <xsl:when test="mods:originInfo/mods:issuance='integrating resource'">
            <xsl:value-of select="'i'" />
          </xsl:when>
          <xsl:when test="mods:originInfo/mods:issuance='serial'">
            <xsl:value-of select="'s'" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'m'" />
          </xsl:otherwise>
        </xsl:choose>
        <!-- 08 -->
        <xsl:value-of select="' '" />
        <!-- 09 -->
        <xsl:value-of select="' '" />
        <!-- 10 -->
        <xsl:value-of select="'2'" />
        <!-- 11 -->
        <xsl:value-of select="'2'" />
        <!-- 12-16 -->
        <xsl:value-of select="'     '" />
        <!-- 17 -->
        <xsl:value-of select="'u'" />
        <!-- 18 -->
        <xsl:value-of select="'u'" />
        <!-- 19 -->
        <xsl:value-of select="' '" />
        <!-- 20-23 -->
        <xsl:value-of select="'4500'" />
      </marc:leader>
      <xsl:if test="@ID">
        <marc:controlfield tag="001">
          <xsl:value-of select="@ID" />
        </marc:controlfield>
      </xsl:if>
      <xsl:call-template name="source" />
      <xsl:apply-templates />
      <xsl:if test="mods:classification[@authority='lcc']">
        <xsl:call-template name="lcClassification" />
      </xsl:if>
      <!-- query for relatedItem host,series -> constituent, preceding -> succeeding, references -> isReferencedBy -->
      <xsl:variable name="mcrId" select="@ID" />
      <xsl:variable name="constituent"
                    select="document(concat('solr:q=%2B(mods.relatedItem.host%3A',$mcrId,'+mods.relatedItem.series%3A',$mcrId,')+%2BobjectType%3Amods&amp;fl=returnId&amp;rows=10000&amp;wt=xml'))/response/result/doc/str[@name='returnId']" />
      <xsl:for-each select="$constituent">
        <xsl:variable name="constituentId" select="text()" />
        <xsl:variable name="constituentMods"
                      select="document(concat('xslTransform:mods:mcrobject:',$constituentId))/mods:mods" />
        <xsl:apply-templates select="$constituentMods" mode="constituent" />
      </xsl:for-each>
      <xsl:variable name="succeeding"
                    select="document(concat('solr:q=%2Bmods.relatedItem.preceding%3A',$mcrId,'+%2BobjectType%3Amods&amp;fl=returnId&amp;rows=10000&amp;wt=xml'))/response/result/doc/str[@name='returnId']" />
      <xsl:for-each select="$succeeding">
        <xsl:variable name="succeedingId" select="text()" />
        <xsl:variable name="succeedingMods"
                      select="document(concat('xslTransform:mods:mcrobject:',$succeedingId))/mods:mods" />
        <xsl:apply-templates select="$succeedingMods" mode="succeeding" />
      </xsl:for-each>
      <xsl:variable name="isReferencedBy"
                    select="document(concat('solr:q=%2Bmods.relatedItem.references%3A',$mcrId,'+%2BobjectType%3Amods&amp;fl=returnId&amp;rows=10000&amp;wt=xml'))/response/result/doc/str[@name='returnId']" />
      <xsl:for-each select="$isReferencedBy">
        <xsl:variable name="isReferencedById" select="text()" />
        <xsl:variable name="isReferencedByMods"
                      select="document(concat('xslTransform:mods:mcrobject:',$isReferencedById))/mods:mods" />
        <xsl:apply-templates select="$isReferencedByMods" mode="isReferencedBy" />
      </xsl:for-each>

      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'035'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="a">
            <xsl:value-of select="@ID" />
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>

      <!-- add field 337 media type -->
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'337'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="a">
            <xsl:value-of select="'Computermedien'" />
          </marc:subfield>
          <marc:subfield code="b">
            <xsl:value-of select="'c'" />
          </marc:subfield>
          <marc:subfield code="2">
            <xsl:value-of select="'rdamedia'" />
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
      <!-- add field 338 carrier type -->
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'338'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="a">
            <xsl:value-of select="'Online-Ressource'" />
          </marc:subfield>
          <marc:subfield code="b">
            <xsl:value-of select="'cr'" />
          </marc:subfield>
          <marc:subfield code="2">
            <xsl:value-of select="'rdacarrier'" />
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </marc:record>
  </xsl:template>

  <xsl:template match="*" />

  <!-- Title Info elements -->
  <xsl:template match="mods:titleInfo[not(ancestor-or-self::mods:subject)][not(@type)][1]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'245'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'1'" />
      </xsl:with-param>
      <!-- add additional space -->
      <xsl:with-param name="ind2" select="mirmarc:titleIndicator(.)" />
      <xsl:with-param name="subfields">
        <xsl:call-template name="titleInfo" />
        <xsl:call-template name="stmtOfResponsibility" />
        <xsl:call-template name="form" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:titleInfo[@type='abbreviated']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'210'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'1'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="titleInfo" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:titleInfo[@type='translated']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'242'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'1'" />
      </xsl:with-param>
      <!-- add additional space -->
      <xsl:with-param name="ind2" select="mirmarc:titleIndicator(.)" />
      <xsl:with-param name="subfields">
        <xsl:call-template name="titleInfo" />
        <!-- add statement of responsibility -->
        <xsl:call-template name="stmtOfResponsibility" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:titleInfo[@type='alternative']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'246'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'3'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="titleInfo" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:titleInfo[@type='uniform'][1]">
    <xsl:choose>
      <xsl:when
          test="../mods:name/mods:role/mods:roleTerm[@type='text']='creator' or mods:name/mods:role/mods:roleTerm[@type='code']='cre'">
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">
            <xsl:value-of select="'240'" />
          </xsl:with-param>
          <xsl:with-param name="ind1">
            <xsl:value-of select="'1'" />
          </xsl:with-param>
          <!-- add additional space -->
          <xsl:with-param name="ind2" select="mirmarc:titleIndicator(.)" />
          <xsl:with-param name="subfields">
            <xsl:call-template name="titleInfo" />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">
            <xsl:value-of select="'130'" />
          </xsl:with-param>
          <!-- add additional space -->
          <xsl:with-param name="ind1" select="mirmarc:titleIndicator(.)" />
          <xsl:with-param name="subfields">
            <xsl:call-template name="titleInfo" />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:titleInfo[@type='uniform'][position()>1]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'730'" />
      </xsl:with-param>
      <!-- add additional space -->
      <xsl:with-param name="ind1" select="mirmarc:titleIndicator(.)" />
      <xsl:with-param name="subfields">
        <xsl:call-template name="titleInfo" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:titleInfo[not(ancestor-or-self::mods:subject)][not(@type)][position()>1]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'246'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'3'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="titleInfo" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Name elements -->
  <xsl:template match="mods:name">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'720'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="mods:namePart" />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <!-- 100 and 700 (main entry / added entry personal name) in one template -->
  <xsl:template match="mods:name[@type='personal']">
    <xsl:choose>
      <xsl:when
          test="mods:role[mods:roleTerm[@type='code']=$marcrelator//category[@ID='cre']//category/@ID and not(../../mods:name/mods:role/mods:roleTerm[@type='code']='cre' or ../preceding-sibling::mods:name/mods:role[mods:roleTerm[@type='code']=$marcrelator//category[@ID='cre']//category/@ID])]">
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">
            <xsl:value-of select="'100'" />
          </xsl:with-param>
          <xsl:with-param name="ind1">
            <xsl:value-of select="'1'" />
          </xsl:with-param>
          <xsl:with-param name="subfields">
            <!-- show mods:displayForm in subfield a -->
            <marc:subfield code="a">
              <xsl:value-of select="mods:displayForm" />
            </marc:subfield>
            <xsl:for-each select="mods:namePart[@type='termsOfAddress']">
              <marc:subfield code="c">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:namePart[@type='date']">
              <marc:subfield code="d">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='text']">
              <marc:subfield code="e">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
              <marc:subfield code="4">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:affiliation">
              <marc:subfield code="u">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:description">
              <marc:subfield code="g">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <!-- add identifier and gnd as source -->
            <xsl:for-each select="mods:nameIdentifier[@type='gnd']">
              <marc:subfield code="0">
                <xsl:choose>
                  <xsl:when test="contains(.,'(DE-588)')">
                    <xsl:value-of select="." />
                  </xsl:when>
                  <xsl:when test="contains(.,'(DE-601)')">
                    <xsl:value-of select="." />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('(DE-588)',.)" />
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">
            <xsl:value-of select="'700'" />
          </xsl:with-param>
          <xsl:with-param name="ind1">
            <xsl:value-of select="'1'" />
          </xsl:with-param>
          <xsl:with-param name="subfields">
            <!-- show mods:displayForm in subfield a -->
            <marc:subfield code="a">
              <xsl:value-of select="mods:displayForm" />
            </marc:subfield>
            <xsl:for-each select="mods:namePart[@type='termsOfAddress']">
              <marc:subfield code="c">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:namePart[@type='date']">
              <marc:subfield code="d">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='text']">
              <marc:subfield code="e">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
              <marc:subfield code="4">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:affiliation">
              <marc:subfield code="u">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <!-- add identifier and gnd as source -->
            <xsl:for-each select="mods:nameIdentifier[@type='gnd']">
              <marc:subfield code="0">
                <xsl:choose>
                  <xsl:when test="contains(.,'(DE-588)')">
                    <xsl:value-of select="." />
                  </xsl:when>
                  <xsl:when test="contains(.,'(DE-601)')">
                    <xsl:value-of select="." />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('(DE-588)',.)" />
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 110 and 710 (main entry / added entry corporate name) in one template -->
  <xsl:template match="mods:name[@type='corporate']">
    <xsl:choose>
      <xsl:when
          test="mods:role[mods:roleTerm[@type='code']=$marcrelator//category[@ID='cre']//category/@ID and not(../../mods:name/mods:role/mods:roleTerm[@type='code']='cre' or ../preceding-sibling::mods:name/mods:role[mods:roleTerm[@type='code']=$marcrelator//category[@ID='cre']//category/@ID])]">
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">
            <xsl:value-of select="'110'" />
          </xsl:with-param>
          <xsl:with-param name="ind1">
            <xsl:value-of select="'2'" />
          </xsl:with-param>
          <xsl:with-param name="subfields">
            <!-- show mods:displayForm in subfield a -->
            <!-- https://www.loc.gov/marc/bibliographic/bd710.html -->
            <marc:subfield code="a">
              <xsl:choose>
                <!-- if university. institute is given -->
                <xsl:when test="contains(mods:displayForm,'.')">
                  <xsl:value-of select="substring-before(mods:displayForm,'.')" />
                </xsl:when>
                <!-- if institution nameParts are given -->
                <xsl:when test="mods:namePart">
                  <xsl:value-of select="mods:namePart[1]" />
                </xsl:when>
                <!-- if only whole institution name is given -->
                <xsl:when test="mods:displayForm">
                  <xsl:value-of select="mods:displayForm" />
                </xsl:when>
                <!-- if no institution name is given, but @valueURI is present -->
                <!-- TODO resolve @valueURI locally (names of institution and universites) -->
                <xsl:when test="@valueURI">
                  <xsl:variable name="categId" select="substring-after(@valueURI, '#')" />
                  <xsl:variable name="institute" select="$institutes//category[@ID=$categId]" />
                  <xsl:apply-templates select="$institute/ancestor-or-self::category[position() = last()]" mode="name110-710-810" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="mods:displayForm" />
                </xsl:otherwise>
              </xsl:choose>
            </marc:subfield>
            <xsl:choose>
              <!-- if university.institute is given -->
              <xsl:when test="contains(mods:displayForm,'.')">
                <marc:subfield code="b">
                  <xsl:value-of select="substring-after(mods:displayForm,'. ')" />
                </marc:subfield>
              </xsl:when>
              <!-- if institution nameParts are given -->
              <xsl:when test="mods:namePart">
                <marc:subfield code="b">
                <xsl:value-of select="mods:namePart[position()>1]" />
                </marc:subfield>
              </xsl:when>
              <!-- if only whole institution name is given (whole name in subfield a, subfield b is empty) -->
              <xsl:when test="mods:displayForm" />
              <!-- if no institution name is given, but @valueURI is present -->
              <!-- TODO resolve @valueURI locally (names of institution and universites) -->
              <xsl:when test="@valueURI">
                <xsl:variable name="categId" select="substring-after(@valueURI, '#')" />
                <xsl:variable name="institute" select="$institutes//category[@ID=$categId]" />
                <xsl:for-each select="$institute/ancestor-or-self::category[position() != last()]">
                  <marc:subfield code="b">
                    <xsl:apply-templates select="." mode="name110-710-810" />
                  </marc:subfield>
                </xsl:for-each>
              </xsl:when>
            </xsl:choose>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='text']">
              <marc:subfield code="e">
                <!-- TODO add labels to modsenhancer/relacode (update) ('issuing body' for 'isb' and 'host institution' for 'his') -->
                <xsl:choose>
                  <xsl:when test="../mods:roleTerm[@type='code']='isb'">
                    <xsl:value-of select="'issuing body'" />
                  </xsl:when>
                  <xsl:when test="../mods:roleTerm[@type='code']='his'">
                    <xsl:value-of select="'host institution'" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="." />
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
              <marc:subfield code="4">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:description">
              <marc:subfield code="g">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <!-- add identifier and gnd as source -->
            <xsl:for-each select="mods:nameIdentifier[@type='gnd']">
              <marc:subfield code="0">
                <xsl:choose>
                  <xsl:when test="contains(.,'(DE-588)')">
                    <xsl:value-of select="." />
                  </xsl:when>
                  <xsl:when test="contains(.,'(DE-601)')">
                    <xsl:value-of select="." />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('(DE-588)',.)" />
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">
            <xsl:value-of select="'710'" />
          </xsl:with-param>
          <xsl:with-param name="ind1">
            <xsl:value-of select="'2'" />
          </xsl:with-param>
          <xsl:with-param name="subfields">
            <!-- show mods:displayForm in subfield a -->
            <marc:subfield code="a">
              <xsl:choose>
                <!-- if university. institute is given -->
                <xsl:when test="contains(mods:displayForm,'.')">
                  <xsl:value-of select="substring-before(mods:displayForm,'.')" />
                </xsl:when>
                <!-- if institution nameParts are given -->
                <xsl:when test="mods:namePart">
                  <xsl:value-of select="mods:namePart[1]" />
                </xsl:when>
                <!-- if only whole institution name is given -->
                <xsl:when test="mods:displayForm">
                  <xsl:value-of select="mods:displayForm" />
                </xsl:when>
                <!-- if no institution name is given, but @valueURI is present -->
                <!-- TODO resolve @valueURI locally (names of institution and universites) -->
                <xsl:when test="@valueURI">
                  <xsl:variable name="categId" select="substring-after(@valueURI, '#')" />
                  <xsl:variable name="institute" select="$institutes//category[@ID=$categId]" />
                  <xsl:apply-templates select="$institute/ancestor-or-self::category[position() = last()]" mode="name110-710-810" />
                </xsl:when>
              </xsl:choose>
            </marc:subfield>
            <xsl:choose>
              <!-- if university.institute is given -->
              <xsl:when test="contains(mods:displayForm,'.')">
                <marc:subfield code="b">
                  <xsl:value-of select="substring-after(mods:displayForm,'. ')" />
                </marc:subfield>
              </xsl:when>
              <!-- if institution nameParts are given -->
              <xsl:when test="mods:namePart">
                <marc:subfield code="b">
                  <xsl:value-of select="mods:namePart[position()>1]" />
                </marc:subfield>
              </xsl:when>
              <!-- if only whole institution name is given (whole name in subfield a, subfield b is empty) -->
              <xsl:when test="mods:displayForm" />
              <!-- if no institution name is given, but @valueURI is present -->
              <!-- TODO resolve @valueURI locally (names of institution and universites) -->
              <xsl:when test="@valueURI">
                <xsl:variable name="categId" select="substring-after(@valueURI, '#')" />
                <xsl:variable name="institute" select="$institutes//category[@ID=$categId]" />
                <xsl:for-each select="$institute/ancestor-or-self::category[position() != last()]">
                  <marc:subfield code="b">
                    <xsl:apply-templates select="." mode="name110-710-810" />
                  </marc:subfield>
                </xsl:for-each>
              </xsl:when>
            </xsl:choose>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='text']">
              <marc:subfield code="e">
                <!-- TODO add labels to modsenhancer/relacode (update) ('issuing body' for 'isb' and 'host institution' for 'his') -->
                <xsl:choose>
                  <xsl:when test="../mods:roleTerm[@type='code']='isb'">
                    <xsl:value-of select="'issuing body'" />
                  </xsl:when>
                  <xsl:when test="../mods:roleTerm[@type='code']='his'">
                    <xsl:value-of select="'host institution'" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="." />
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
              <marc:subfield code="4">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:description">
              <marc:subfield code="g">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <!-- add identifier and gnd as source -->
            <xsl:for-each select="mods:nameIdentifier[@type='gnd']">
              <marc:subfield code="0">
                <xsl:choose>
                  <xsl:when test="contains(.,'(DE-588)')">
                    <xsl:value-of select="." />
                  </xsl:when>
                  <xsl:when test="contains(.,'(DE-601)')">
                    <xsl:value-of select="." />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('(DE-588)',.)" />
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="category" mode="name110-710-810">
    <xsl:choose>
      <xsl:when test="label[@xml:lang='en']">
        <xsl:value-of select="label[@xml:lang='en']/@text" />
      </xsl:when>
      <xsl:when test="label[@xml:lang='de']">
        <xsl:value-of select="label[@xml:lang='de']/@text" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="label/@text[1]" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 111 and 711 (main entry / added entry meeting name) in one template -->
  <xsl:template match="mods:name[@type='conference']">
    <xsl:choose>
      <xsl:when
          test="mods:role[mods:roleTerm[@type='code']=$marcrelator//category[@ID='cre']//category/@ID and not(../../mods:name/mods:role/mods:roleTerm[@type='code']='cre' or ../preceding-sibling::mods:name/mods:role[mods:roleTerm[@type='code']=$marcrelator//category[@ID='cre']//category/@ID])]">
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">
            <xsl:value-of select="'111'" />
          </xsl:with-param>
          <xsl:with-param name="ind1">
            <xsl:value-of select="'2'" />
          </xsl:with-param>
          <xsl:with-param name="subfields">
            <marc:subfield code="a">
              <xsl:value-of select="mods:namePart" />
            </marc:subfield>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
              <marc:subfield code="4">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <!-- add identifier and gnd as source -->
            <xsl:for-each select="mods:nameIdentifier[@type='gnd']">
              <marc:subfield code="0">
                <xsl:choose>
                  <xsl:when test="contains(.,'(DE-588)')">
                    <xsl:value-of select="." />
                  </xsl:when>
                  <xsl:when test="contains(.,'(DE-601)')">
                    <xsl:value-of select="." />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('(DE-588)',.)" />
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">
            <xsl:value-of select="'711'" />
          </xsl:with-param>
          <xsl:with-param name="ind1">
            <xsl:value-of select="'2'" />
          </xsl:with-param>
          <xsl:with-param name="subfields">
            <marc:subfield code="a">
              <xsl:value-of select="mods:namePart" />
            </marc:subfield>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
              <marc:subfield code="4">
                <xsl:value-of select="." />
              </marc:subfield>
            </xsl:for-each>
            <!-- add identifier and gnd as source -->
            <xsl:for-each select="mods:nameIdentifier[@type='gnd']">
              <marc:subfield code="0">
                <xsl:choose>
                  <xsl:when test="contains(.,'(DE-588)')">
                    <xsl:value-of select="." />
                  </xsl:when>
                  <xsl:when test="contains(.,'(DE-601)')">
                    <xsl:value-of select="." />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('(DE-588)',.)" />
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:genre[@authority = 'content' and @type='musical composition']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'047'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:value-of select="'7'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="." />
        </marc:subfield>
        <xsl:for-each select="@authority">
          <marc:subfield code='2'>
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:genre[@authority='marcgt' or not(@authority)][1]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'655'" />
      </xsl:with-param>
      <!-- set second indicator equal to '4' (no source specified) -->
      <xsl:with-param name="ind2">
        <xsl:value-of select="'4'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:choose>
          <!-- two different terms-->
          <xsl:when test="../mods:genre[@authority='marcgt'][1]/text()!=../mods:genre[@authority='marcgt'][2]/text()">
            <marc:subfield code="a">
              <xsl:value-of
                  select="concat(../mods:genre[@authority='marcgt'][1],', ',../mods:genre[@authority='marcgt'][2])" />
            </marc:subfield>
          </xsl:when>
          <!-- one term only -->
          <xsl:otherwise>
            <marc:subfield code="a">
              <xsl:value-of select="../mods:genre[@authority='marcgt'][1]" />
            </marc:subfield>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- add field 336 content type with coding for subfield b -->
  <xsl:template match="mods:typeOfResource">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'336'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="../mods:typeOfResource" />
        </marc:subfield>
        <marc:subfield code="b">
          <xsl:choose>
            <xsl:when test="../mods:typeOfResource/text()='text'">
              <xsl:value-of select="'txt'" />
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='cartographic'">
              <xsl:value-of select="'crd'" />
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='notated music'">
              <xsl:value-of select="'ntm'" />
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='sound recording'">
              <xsl:value-of select="'prm'" />
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='sound recording-musical'">
              <xsl:value-of select="'prm'" />
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='sound recording-nonmusical'">
              <xsl:value-of select="'snd'" />
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='still image'">
              <xsl:value-of select="'stdi'" />
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='moving image'">
              <xsl:value-of select="'tdi'" />
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='three dimensional object'">
              <xsl:value-of select="'tdf'" />
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='software, multimedia'">
              <xsl:value-of select="'cop'" />
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='mixed material'">
              <xsl:value-of select="'zzz'" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'xxx'" />
            </xsl:otherwise>
          </xsl:choose>
        </marc:subfield>
        <marc:subfield code="2">
          <xsl:value-of select="'rdacontent'" />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Origin Info elements -->
  <xsl:template match="mods:originInfo">
    <xsl:for-each select="mods:place/mods:placeTerm[@type='code'][@authority='iso3166']">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'044'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code='c'>
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:if test="mods:dateCaptured[@encoding='iso8601']">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'033'" />
        </xsl:with-param>
        <xsl:with-param name="ind1">
          <xsl:choose>
            <xsl:when test="mods:dateCaptured[@point='start']|mods:dateCaptured[@point='end']">
              <xsl:value-of select="'2'" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'0'" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="ind2">
          <xsl:value-of select="'0'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <xsl:for-each select="mods:dateCaptured">
            <marc:subfield code='a'>
              <xsl:value-of select="." />
            </marc:subfield>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="mods:dateModified|mods:dateCreated|mods:dateValid">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'046'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <xsl:for-each select="mods:dateModified">
            <marc:subfield code='j'>
              <xsl:value-of select="." />
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:dateCreated[@point='start']|mods:dateCreated[not(@point)]">
            <marc:subfield code='k'>
              <xsl:value-of select="." />
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:dateCreated[@point='end']">
            <marc:subfield code='l'>
              <xsl:value-of select="." />
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:dateValid[@point='start']|mods:dateValid[not(@point)]">
            <marc:subfield code='m'>
              <xsl:value-of select="." />
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:dateValid[@point='end']">
            <marc:subfield code='n'>
              <xsl:value-of select="." />
            </marc:subfield>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:for-each select="mods:edition">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'250'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code='a'>
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="mods:frequency">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'310'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code='a'>
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:if
        test="mods:place/mods:placeTerm[@type='text'] or mods:publisher or mods:dateIssued[../@eventType!='creation'] or mods:dateCreated">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:choose>
            <!-- add @eventType as criterion -->
            <xsl:when test="@eventType='publication' or @eventType='production'
            or @eventType='manufacture' or @eventType='distribution'">
              <xsl:value-of select="'264'" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'260'" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="ind2">
          <xsl:choose>
            <xsl:when test="@eventType='production'">
              <xsl:value-of select="'0'" />
            </xsl:when>
            <xsl:when test="@eventType='publication'">
              <xsl:value-of select="'1'" />
            </xsl:when>
            <xsl:when test="@eventType='manufacture'">
              <xsl:value-of select="'2'" />
            </xsl:when>
            <xsl:when test="@eventType='distribution'">
              <xsl:value-of select="'3'" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="' '" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <xsl:for-each select="mods:place/mods:placeTerm[@type='text']">
            <marc:subfield code='a'>
              <xsl:value-of select="." />
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:publisher">
            <marc:subfield code='b'>
              <xsl:value-of select="." />
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:dateIssued">
            <marc:subfield code='c'>
              <!-- if only one date (neither start  nor end date) is present -->
              <xsl:if test="not(@point)">
                <xsl:value-of select="." />
              </xsl:if>
              <!-- if start and end dates are present -->
              <xsl:if test="@point='start' and ../mods:dateIssued[@point='end']">
                <xsl:value-of
                    select="concat(../mods:dateIssued[@point='start'],'-',../mods:dateIssued[@point='end'])" />
              </xsl:if>
              <!-- if only a start date is present -->
              <xsl:if test="@point='start'and not(../mods:dateIssued[@point='end'])">
                <xsl:value-of select="concat(../mods:dateIssued[@point='start'],'-')" />
              </xsl:if>
              <xsl:if test="@qualifier='questionable'">
                <xsl:value-of select="'?'" />
              </xsl:if>
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:dateCreated">
            <!-- add parentheses -->
            <marc:subfield code='g'>
              <xsl:value-of select="concat('(',.,')')" />
            </marc:subfield>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Language -->
  <!-- use international language code classification -->
  <!-- TODO: resolve language code classification locally-->
  <xsl:template match="mods:language[mods:languageTerm]">
    <xsl:variable name="lang" select="mods:languageTerm" />
    <xsl:variable name="biblLang" select="$rfc5646//category[@ID=$lang]/label[@xml:lang='x-bibl']/@text" />
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'041'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:choose>
          <xsl:when test="mods:languageTerm[@objectPart='text/sound track']">
            <marc:subfield code='a'>
              <xsl:value-of select="$biblLang" />
            </marc:subfield>
          </xsl:when>
          <xsl:when
              test="mods:languageTerm[@objectPart='summary or abstract' or @objectPart='summary' or @objectPart='abstract']">
            <marc:subfield code='b'>
              <xsl:value-of select="$biblLang" />
            </marc:subfield>
          </xsl:when>
          <xsl:when test="mods:languageTerm[@objectPart='sung or spoken text']">
            <marc:subfield code='d'>
              <xsl:value-of select="$biblLang" />
            </marc:subfield>
          </xsl:when>
          <xsl:when test="mods:languageTerm[@objectPart='librettos' or @objectPart='libretto']">
            <marc:subfield code='e'>
              <xsl:value-of select="$biblLang" />
            </marc:subfield>
          </xsl:when>
          <xsl:when test="mods:languageTerm[@objectPart='table of contents']">
            <marc:subfield code='f'>
              <xsl:value-of select="$biblLang" />
            </marc:subfield>
          </xsl:when>
          <xsl:when
              test="mods:languageTerm[@objectPart='accompanying material other than librettos' or @objectPart='accompanying material']">
            <marc:subfield code='g'>
              <xsl:value-of select="$biblLang" />
            </marc:subfield>
          </xsl:when>
          <xsl:when
              test="mods:languageTerm[@objectPart='original and/or intermediate translations of text' or @objectPart='translation']">
            <marc:subfield code='h'>
              <xsl:value-of select="$biblLang" />
            </marc:subfield>
          </xsl:when>
          <xsl:when test="mods:languageTerm[@objectPart='subtitles or captions' or @objectPart='subtitle or caption']">
            <marc:subfield code='j'>
              <xsl:value-of select="$biblLang" />
            </marc:subfield>
          </xsl:when>
          <xsl:otherwise>
            <marc:subfield code='a'>
              <xsl:value-of select="$biblLang" />
            </marc:subfield>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:language/mods:languageTerm[@authority='iso639-2b']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'041'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:language/mods:languageTerm[@authority='rfc3066']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'041'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:value-of select="'7'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="." />
        </marc:subfield>
        <marc:subfield code='2'>
          <xsl:value-of select="'rfc3066'" />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:language/mods:languageTerm[@authority='rfc3066']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'546'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='b'>
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Physical Description -->
  <xsl:template match="mods:physicalDescription">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="mods:extent">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'300'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:form[@type='material']|mods:form[@type='technique']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:choose>
          <xsl:when test="@type='material'">
            <xsl:value-of select="'340'" />
          </xsl:when>
          <xsl:when test="@type='technique'">
            <xsl:value-of select="'340'" />
          </xsl:when>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:if test="not(@type='technique')">
          <marc:subfield code="a">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:if>
        <!-- add subfield b-->
        <xsl:if test="@code!=''">
          <marc:subfield code="b">
            <xsl:value-of select="@code" />
          </marc:subfield>
        </xsl:if>
        <xsl:if test="@type='technique'">
          <marc:subfield code="d">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:if>
        <xsl:if test="@authority">
          <marc:subfield code="2">
            <xsl:value-of select="@authority" />
          </marc:subfield>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Abstract -->
  <xsl:template match="mods:abstract">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'520'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:choose>
          <xsl:when test="@displayLabel='Subject'">
            <xsl:value-of select="'0'" />
          </xsl:when>
          <xsl:when test="@displayLabel='Review'">
            <xsl:value-of select="'1'" />
          </xsl:when>
          <xsl:when test="@displayLabel='Scope and content'">
            <xsl:value-of select="'2'" />
          </xsl:when>
          <xsl:when test="@displayLabel='Abstract'">
            <xsl:value-of select="'2'" />
          </xsl:when>
          <xsl:when test="@displayLabel='Content advice'">
            <xsl:value-of select="'4'" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="' '" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <!-- delete CR and NL -->
          <xsl:value-of select="translate(., '&#10;&#13;', ' ')" />
        </marc:subfield>
        <xsl:for-each select="@xlink:href">
          <marc:subfield code="u">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Table of Contents -->
  <xsl:template match="mods:tableOfContents">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'505'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:choose>
          <xsl:when test="@displayLabel='Contents'">
            <xsl:value-of select="'0'" />
          </xsl:when>
          <xsl:when test="@displayLabel='Incomplete contents'">
            <xsl:value-of select="'1'" />
          </xsl:when>
          <xsl:when test="@displayLabel='Partial contents'">
            <xsl:value-of select="'2'" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'0'" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
        <xsl:for-each select="@xlink:href">
          <marc:subfield code="u">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Target Audience -->
  <xsl:template match="mods:targetAudience[not(@authority)] | mods:targetAudience[@authority!='marctarget']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'521'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:choose>
          <xsl:when test="@displayLabel='Reading grade level'">
            <xsl:value-of select="'0'" />
          </xsl:when>
          <xsl:when test="@displayLabel='Interest age level'">
            <xsl:value-of select="'1'" />
          </xsl:when>
          <xsl:when test="@displayLabel='Interest grade level'">
            <xsl:value-of select="'2'" />
          </xsl:when>
          <xsl:when test="@displayLabel='Special audience characteristics'">
            <xsl:value-of select="'3'" />
          </xsl:when>
          <xsl:when test="@displayLabel='Motivation or interest level'">
            <xsl:value-of select="'3'" />
          </xsl:when>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Note -->
  <xsl:template match="mods:note[not(@type='statement of responsibility')]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:choose>
          <xsl:when test="@type='performers'">
            <xsl:value-of select="'511'" />
          </xsl:when>
          <xsl:when test="@type='venue'">
            <xsl:value-of select="'518'" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'500'" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:for-each select="@xlink:href">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'856'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code='u'>
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:accessCondition">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:choose>
          <!-- changes attribute 'restrictionOnAccess' to 'embargo'-->
          <xsl:when test="@type='embargo'">
            <xsl:value-of select="'506'" />
          </xsl:when>
          <xsl:when test="@type='useAndReproduction'">
            <xsl:value-of select="'540'" />
          </xsl:when>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="concat('embargo until ',.)" />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="source">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'040'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <!-- set cataloging language to german -->
        <marc:subfield code="b">
          <xsl:value-of select="'ger'" />
        </marc:subfield>
        <!-- set cataloging source to 'DE-601' (GBV) -->
        <marc:subfield code="c">
          <xsl:value-of select="'DE-601'" />
        </marc:subfield>
        <!-- set cataloging rules to RDA -->
        <marc:subfield code="e">
          <xsl:value-of select="'rda'" />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:subject">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="mods:subject[local-name(*[1])='titleInfo']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'630'" />
      </xsl:with-param>
      <xsl:with-param name="ind1" select="mirmarc:titleIndicator(mods:titleInfo)" />
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:for-each select="mods:titleInfo">
          <xsl:call-template name="titleInfo" />
        </xsl:for-each>
        <xsl:apply-templates select="*[position()>1]" />
      </xsl:with-param>
    </xsl:call-template>

  </xsl:template>

  <xsl:template match="mods:subject[local-name(*[1])='name']">
    <xsl:for-each select="*[1]">
      <xsl:choose>
        <xsl:when test="@type='personal'">
          <xsl:call-template name="datafield">
            <xsl:with-param name="tag">
              <xsl:value-of select="'600'" />
            </xsl:with-param>
            <xsl:with-param name="ind1">
              <xsl:value-of select="'1'" />
            </xsl:with-param>
            <xsl:with-param name="ind2">
              <xsl:call-template name="authorityInd" />
            </xsl:with-param>
            <xsl:with-param name="subfields">
              <marc:subfield code="a">
                <xsl:value-of select="mods:namePart" />
              </marc:subfield>
              <xsl:for-each select="mods:namePart[@type='termsOfAddress']">
                <marc:subfield code="c">
                  <xsl:value-of select="." />
                </marc:subfield>
              </xsl:for-each>
              <xsl:for-each select="mods:namePart[@type='date']">
                <marc:subfield code="d">
                  <xsl:value-of select="." />
                </marc:subfield>
              </xsl:for-each>
              <xsl:for-each select="mods:role/mods:roleTerm[@type='text']">
                <marc:subfield code="e">
                  <xsl:value-of select="." />
                </marc:subfield>
              </xsl:for-each>
              <xsl:for-each select="mods:affiliation">
                <marc:subfield code="u">
                  <xsl:value-of select="." />
                </marc:subfield>
              </xsl:for-each>
              <xsl:apply-templates select="*[position()>1]" />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="@type='corporate'">
          <xsl:call-template name="datafield">
            <xsl:with-param name="tag">
              <xsl:value-of select="'610'" />
            </xsl:with-param>
            <xsl:with-param name="ind1">
              <xsl:value-of select="'2'" />
            </xsl:with-param>
            <xsl:with-param name="ind2">
              <xsl:call-template name="authorityInd" />
            </xsl:with-param>
            <xsl:with-param name="subfields">
              <marc:subfield code="a">
                <xsl:value-of select="mods:namePart[1]" />
              </marc:subfield>
              <marc:subfield code="b">
                <xsl:value-of select="mods:namePart[position()>1]" />
              </marc:subfield>
              <xsl:for-each select="mods:role/mods:roleTerm[@type='text']">
                <marc:subfield code="e">
                  <xsl:value-of select="." />
                </marc:subfield>
              </xsl:for-each>
              <xsl:apply-templates select="ancestor-or-self::mods:subject/*[position()>1]" />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="@type='conference'">
          <xsl:call-template name="datafield">
            <xsl:with-param name="tag">
              <xsl:value-of select="'611'" />
            </xsl:with-param>
            <xsl:with-param name="ind1">
              <xsl:value-of select="'2'" />
            </xsl:with-param>
            <xsl:with-param name="ind2">
              <xsl:call-template name="authorityInd" />
            </xsl:with-param>
            <xsl:with-param name="subfields">
              <marc:subfield code="a">
                <xsl:value-of select="mods:namePart" />
              </marc:subfield>
              <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
                <marc:subfield code="4">
                  <xsl:value-of select="." />
                </marc:subfield>
              </xsl:for-each>
              <xsl:apply-templates select="*[position()>1]" />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- mods:geographic not lcsh -->
  <xsl:template
      match="mods:subject[(@authority!='lcsh' and @authority!='lcshac' and @authority!='mesh' and @authority!='csh' and @authority!='nal' and @authority!='rvm') or not(@authority)]/mods:geographic[(@authority!='lcsh' and @authority!='lcshac' and @authority!='mesh' and @authority!='csh' and @authority!='nal' and @authority!='rvm') or not(@authority)]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'651'" />
      </xsl:with-param>
      <!-- set first indicator equal to ' ', second indicator depending on source -->
      <xsl:with-param name="ind1" />
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <!-- put all topical terms in subfield a, one field 651a per term -->
        <xsl:for-each select=".">
          <marc:subfield code="a">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
        <!-- add subfield 2 (source) -->
        <xsl:for-each select=".">
          <xsl:choose>
            <xsl:when test="./@authority">
              <marc:subfield code="2">
                <xsl:value-of select="@authority" />
              </marc:subfield>
            </xsl:when>
            <xsl:when test="../@authority">
              <marc:subfield code="2">
                <xsl:value-of select="../@authority" />
              </marc:subfield>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- mods:geographic lcsh -->
  <xsl:template
      match="mods:subject[@authority='lcsh' or @authority='lcshac' or @authority='mesh' or @authority='csh' or @authority='nal' or @authority='rvm'][local-name(*[1])='geographic']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'651'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="*[1]" />
        </marc:subfield>
        <xsl:apply-templates select="*[position()&gt;1]" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- mods:temporal not lcsh -->
  <xsl:template
      match="mods:subject[(@authority!='lcsh' and @authority!='lcshac' and @authority!='mesh' and @authority!='csh' and @authority!='nal' and @authority!='rvm') or not(@authority)]/mods:temporal[(@authority!='lcsh' and @authority!='lcshac' and @authority!='mesh' and @authority!='csh' and @authority!='nal' and @authority!='rvm') or not(@authority)]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'650'" />
      </xsl:with-param>
      <!-- set first indicator equal to ' ', second indicator depending on source -->
      <xsl:with-param name="ind1" />
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <!-- put all topical terms in subfield a, one field 650a per term -->
        <xsl:for-each select=".">
          <marc:subfield code="a">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
        <!-- add subfield 2 (source) -->
        <xsl:for-each select=".">
          <xsl:choose>
            <xsl:when test="./@authority">
              <marc:subfield code="2">
                <xsl:value-of select="@authority" />
              </marc:subfield>
            </xsl:when>
            <xsl:when test="../@authority">
              <marc:subfield code="2">
                <xsl:value-of select="../@authority" />
              </marc:subfield>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- mods:temporal lcsh -->
  <xsl:template
      match="mods:subject[@authority='lcsh' or @authority='lcshac' or @authority='mesh' or @authority='csh' or @authority='nal' or @authority='rvm'][local-name(*[1])='temporal']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'650'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="*[1]" />
        </marc:subfield>
        <xsl:apply-templates select="*[position()>1]" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:subject/mods:geographicCode[@authority]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'043'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:for-each select="self::mods:geographicCode[@authority='marcgac']">
          <marc:subfield code='a'>
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="self::mods:geographicCode[@authority='iso3166']">
          <marc:subfield code='c'>
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:subject/mods:heirarchialGeographic">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'752'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:for-each select="mods:country">
          <marc:subfield code="a">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="mods:state">
          <marc:subfield code="b">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="mods:county">
          <marc:subfield code="c">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="mods:city">
          <marc:subfield code="d">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:subject/mods:cartographics">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'255'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:for-each select="mods:coordinates">
          <marc:subfield code="c">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="mods:scale">
          <marc:subfield code="a">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="mods:projection">
          <marc:subfield code="b">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:subject/mods:occupation">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'656'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- mods:topic not lcsh -->
  <xsl:template
      match="mods:subject[(@authority!='lcsh' and @authority!='lcshac' and @authority!='mesh' and @authority!='csh' and @authority!='nal' and @authority!='rvm') or not(@authority)]/mods:topic[(@authority!='lcsh' and @authority!='lcshac' and @authority!='mesh' and @authority!='csh' and @authority!='nal' and @authority!='rvm') or not(@authority)]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'650'" />
      </xsl:with-param>
      <!-- set first indicator equal to ' ', second indicator depending on source -->
      <xsl:with-param name="ind1" />
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <!-- put all topical terms in subfield a, one field 650a per term -->
        <xsl:for-each select=".">
          <marc:subfield code="a">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
        <!-- add subfield 2 (source) -->
        <xsl:for-each select=".">
          <xsl:choose>
            <xsl:when test="./@authority">
              <marc:subfield code="2">
                <xsl:value-of select="./@authority" />
              </marc:subfield>
            </xsl:when>
            <xsl:when test="../@authority">
              <marc:subfield code="2">
                <xsl:value-of select="../@authority" />
              </marc:subfield>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- mods:topic lcsh -->
  <xsl:template
      match="mods:subject[@authority='lcsh' or @authority='lcshac' or @authority='mesh' or @authority='csh' or @authority='nal' or @authority='rvm'][local-name(*[1])='topic']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'650'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'1'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="*[1]" />
        </marc:subfield>
        <xsl:apply-templates select="*[position()>1]" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template
      match="mods:subject[@authority='lcsh' or @authority='lcshac' or @authority='mesh' or @authority='csh' or @authority='nal' or @authority='rvm']/mods:topic">
    <marc:subfield code="x">
      <xsl:value-of select="." />
    </marc:subfield>
  </xsl:template>

  <xsl:template
      match="mods:subject[@authority='lcsh' or @authority='lcshac' or @authority='mesh' or @authority='csh' or @authority='nal' or @authority='rvm']/mods:temporal">
    <marc:subfield code="y">
      <xsl:value-of select="." />
    </marc:subfield>
  </xsl:template>

  <xsl:template
      match="mods:subject[@authority='lcsh' or @authority='lcshac' or @authority='mesh' or @authority='csh' or @authority='nal' or @authority='rvm']/mods:geographic">
    <marc:subfield code="z">
      <xsl:value-of select="." />
    </marc:subfield>
  </xsl:template>

  <xsl:template name="titleInfo">
    <xsl:for-each select="mods:title">
      <marc:subfield code="a">
        <!-- add additional space -->
        <xsl:if test="../mods:nonSort">
          <xsl:value-of select="concat(../mods:nonSort,' ')" />
        </xsl:if>
        <xsl:value-of select="." />
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:subTitle">
      <marc:subfield code="b">
        <xsl:value-of select="." />
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:partNumber">
      <marc:subfield code="n">
        <xsl:value-of select="." />
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:partName">
      <marc:subfield code="p">
        <xsl:value-of select="." />
      </marc:subfield>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="stmtOfResponsibility">
    <xsl:choose>
      <xsl:when test="../mods:note[@type='statement of responsibility']">
        <marc:subfield code='c'>
          <xsl:value-of select="../mods:note[@type='statement of responsibility']" />
        </marc:subfield>
      </xsl:when>
      <xsl:otherwise>
        <marc:subfield code="c">
          <xsl:for-each
              select="/mods:mods/mods:name/mods:displayForm[../mods:role/mods:roleTerm[@type='code']!='rev'][../mods:role/mods:roleTerm[@type='code']!='pbl'][../mods:role/mods:roleTerm[@type='code']!='dst']">
            <xsl:value-of select="." />
            <xsl:if test="position()!=last()">
              <xsl:value-of select="';'" />
            </xsl:if>
          </xsl:for-each>
        </marc:subfield>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Classification -->
  <xsl:template match="mods:classification[@authority='ddc']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'082'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
        <xsl:for-each select="@edition">
          <marc:subfield code="2">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='udc']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'080'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='nlm']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'060'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:value-of select="'4'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='sudocs']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'086'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='candocs']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'086'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'1'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='content']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'084'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- add other classifications  (e.g. sdnb, rvk, bkl) -->
  <xsl:template match="mods:classification[@authority]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'084'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
        <marc:subfield code="2">
          <xsl:value-of select="./@authority" />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="lcClassification">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'050'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:choose>
          <xsl:when
              test="../mods:recordInfo/mods:recordContentSource='DLC' or ../mods:recordInfo/mods:recordContentSource='Library of Congress'">
            0
          </xsl:when>
          <!-- set indicator equal to '4' (assigned by agency other than LC) -->
          <xsl:otherwise>
            <xsl:value-of select="'4'" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:for-each select="mods:classification[@authority='lcc']">
          <marc:subfield code="a">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Identifiers -->
  <xsl:template match="mods:identifier[@type='doi'] | mods:identifier[@type='hdl']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'024'" />
      </xsl:with-param>
      <!-- set first indicator equal to '7' (source specified in subfield 2) -->
      <xsl:with-param name="ind1">
        <xsl:value-of select="'7'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
        <marc:subfield code="2">
          <xsl:value-of select="@type" />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='isbn']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'020'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">
                <xsl:value-of select="'z'" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'a'" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='isrc']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'024'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">
                <xsl:value-of select="'z'" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'a'" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='ismn']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'024'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'2'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">
                <xsl:value-of select="'z'" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'a'" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='issn'] | mods:identifier[@type='issn-l'] ">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'022'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">
                <xsl:value-of select="'z'" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'a'" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='issue number']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'028'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='lccn']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'010'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">
                <xsl:value-of select="'z'" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'a'" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='matrix number']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'028'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'1'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='music publisher']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'028'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'3'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='music plate']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'028'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'2'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='sici']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'024'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'4'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">
                <xsl:value-of select="'z'" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'a'" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='stocknumber']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'037'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='uri']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'856'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="u">
          <xsl:value-of select="." />
        </marc:subfield>
        <marc:subfield code="y">
          <xsl:value-of select="./@type"/>
        </marc:subfield>
        <xsl:call-template name="mediaType" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:location[mods:url]">
    <xsl:for-each select="mods:url">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'856'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="u">
            <xsl:value-of select="." />
          </marc:subfield>
          <xsl:for-each select="@access">
            <marc:subfield code="y">
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="@displayLabel">
            <marc:subfield code="3">
              <xsl:value-of select="." />
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="@dateLastAccessed">
            <marc:subfield code="z">
              <xsl:value-of select="concat('Last accessed: ',.)" />
            </marc:subfield>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='upc']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'024'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'1'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">
                <xsl:value-of select="'z'" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'a'" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='videorecording']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'028'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'4'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="authorityInd">
    <xsl:choose>
      <xsl:when test="@authority='lcsh' or ../@authority='lcsh'">
        <xsl:value-of select="'0'" />
      </xsl:when>
      <xsl:when test="@authority='lcshac' or ../@authority='lcshac'">
        <xsl:value-of select="'1'" />
      </xsl:when>
      <xsl:when test="@authority='mesh' or ../@authority='mesh'">
        <xsl:value-of select="'2'" />
      </xsl:when>
      <xsl:when test="@authority='csh' or ../@authority='csh'">
        <xsl:value-of select="'3'" />
      </xsl:when>
      <xsl:when test="@authority='nal' or ../@authority='nal'">
        <xsl:value-of select="'5'" />
      </xsl:when>
      <xsl:when test="@authority='rvm' or ../@authority='rvm'">
        <xsl:value-of select="'6'" />
      </xsl:when>
      <xsl:when test="@authority or ../@authority">
        <xsl:value-of select="'7'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'4'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:relatedItem/mods:identifier[@type='uri']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'856'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:value-of select="'2'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="u">
          <xsl:value-of select="." />
        </marc:subfield>
        <xsl:call-template name="mediaType" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:location[mods:physicalLocation]">
    <xsl:for-each select="mods:physicalLocation">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'852'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="a">
            <xsl:value-of select="." />
          </marc:subfield>
          <xsl:for-each select="@displayLabel">
            <marc:subfield code="3">
              <xsl:value-of select="." />
            </marc:subfield>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:location[mods:physicalLocation[@xlink]]">
    <xsl:for-each select="mods:physicalLocation">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'852'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="u">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="mods:location[mods:uri]">
    <xsl:for-each select="mods:uri">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'852'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield>
            <xsl:choose>
              <xsl:when test="@displayLabel='content'">
                <xsl:value-of select="'3'" />
              </xsl:when>
              <xsl:when test="@dateLastAccessed='content'">
                <xsl:value-of select="'z'" />
              </xsl:when>
              <xsl:when test="@note='contents of subfield'">
                <xsl:value-of select="'z'" />
              </xsl:when>
              <xsl:when test="@access='preview'">
                <xsl:value-of select="'3'" />
              </xsl:when>
              <xsl:when test="@access='raw object'">
                <xsl:value-of select="'3'" />
              </xsl:when>
              <xsl:when test="@access='object in context'">
                <xsl:value-of select="'3'" />
              </xsl:when>
              <xsl:when test="@access='primary display'">
                <xsl:value-of select="'z'" />
              </xsl:when>
            </xsl:choose>
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:extension">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'887'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="mediaType">
    <xsl:if test="../mods:physicalDescription/mods:internetMediaType">
      <marc:subfield code="q">
        <xsl:value-of select="../mods:physicalDescription/mods:internetMediaType" />
      </marc:subfield>
    </xsl:if>
  </xsl:template>

  <xsl:template name="form">
    <xsl:if test="../mods:physicalDescription/mods:form[@authority='gmd']">
      <marc:subfield code="h">
        <xsl:value-of select="../mods:physicalDescription/mods:form[@authority='gmd']" />
      </marc:subfield>
    </xsl:if>
  </xsl:template>

  <!-- use definded query for isReferencedBy (see above) -->
  <xsl:template match="mods:mods" mode="isReferencedBy">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'510'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of
              select="concat(mods:titleInfo/mods:title[not(ancestor-or-self::mods:titleInfo/@type)],' (',mods:identifier[@type='local']|@xlink:href|@ID, ')')" />
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='series']">
    <!-- 490 - use field 490 instead of 440, set first indicator equal to '0' (series not traced)-->
    <xsl:for-each select="mods:titleInfo">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:value-of select="'490'" />
        </xsl:with-param>
        <xsl:with-param name="ind1">
          <xsl:value-of select="'0'" />
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <xsl:call-template name="titleInfo" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <!-- 830-->
    <xsl:for-each select="mods:titleInfo">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">830</xsl:with-param>
        <xsl:with-param name="subfields">
          <xsl:call-template name="titleInfo"/>
          <xsl:for-each select="../@xlink:href">
            <marc:subfield code="w">
              <xsl:value-of select="../@xlink:href"/>
            </marc:subfield>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <!-- 810 -->
    <xsl:for-each select="mods:name">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:choose>
            <xsl:when test="@type='personal'">
              <xsl:value-of select="'800'" />
            </xsl:when>
            <xsl:when test="@type='corporate'">
              <xsl:value-of select="'810'" />
            </xsl:when>
            <xsl:when test="@type='conference'">
              <xsl:value-of select="'811'" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'800'" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <!-- set first indicator depending on type of series added entry -->
        <xsl:with-param name="ind1">
          <xsl:choose>
            <xsl:when test="@type='personal'">
              <xsl:value-of select="'1'" />
            </xsl:when>
            <xsl:when test="@type='corporate'">
              <xsl:value-of select="'2'" />
            </xsl:when>
            <xsl:when test="@type='conference'">
              <xsl:value-of select="'2'" />
            </xsl:when>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="a">
            <xsl:choose>
              <!-- if university. institute is given -->
              <xsl:when test="contains(mods:displayForm,'.')">
                <xsl:value-of select="substring-before(mods:displayForm,'.')" />
              </xsl:when>
              <!-- if institution nameParts are given -->
              <xsl:when test="mods:namePart">
                <xsl:value-of select="mods:namePart[1]" />
              </xsl:when>
              <!-- if only whole institution name is given -->
              <xsl:when test="mods:displayForm">
                <xsl:value-of select="mods:displayForm" />
              </xsl:when>
              <!-- if no institution name is given, but @valueURI is present -->
              <!-- TODO resolve @valueURI locally (names of institution and universites) -->
              <xsl:when test="@valueURI">
                <xsl:variable name="categId" select="substring-after(@valueURI, '#')" />
                <xsl:variable name="institute" select="$institutes//category[@ID=$categId]" />
                <xsl:apply-templates select="$institute/ancestor-or-self::category[position() = last()]" mode="name110-710-810" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="mods:displayForm" />
              </xsl:otherwise>
            </xsl:choose>
          </marc:subfield>
          <xsl:choose>
            <!-- if university.institute is given -->
            <xsl:when test="contains(mods:displayForm,'.')">
              <marc:subfield code="b">
                <xsl:value-of select="substring-after(mods:displayForm,'. ')" />
              </marc:subfield>
            </xsl:when>
            <!-- if institution nameParts are given -->
            <xsl:when test="mods:namePart">
              <marc:subfield code="b">
                <xsl:value-of select="mods:namePart[position()>1]" />
              </marc:subfield>
            </xsl:when>
            <!-- if only whole institution name is given (whole name in subfield a, subfield b is empty) -->
            <xsl:when test="mods:displayForm" />
            <!-- if no institution name is given, but @valueURI is present -->
            <!-- TODO resolve @valueURI locally (names of institution and universites) -->
            <xsl:when test="@valueURI">
              <xsl:variable name="categId" select="substring-after(@valueURI, '#')" />
              <xsl:variable name="institute" select="$institutes//category[@ID=$categId]" />
              <xsl:for-each select="$institute/ancestor-or-self::category[position() != last()]">
                <marc:subfield code="b">
                  <xsl:apply-templates select="." mode="name110-710-810" />
                </marc:subfield>
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="@type='personal'">
            <marc:subfield code="c">
              <xsl:value-of select="mods:namePart[@type='termsOfAddress']" />
            </marc:subfield>
            <marc:subfield code="d">
              <xsl:value-of select="mods:namePart[@type='date']" />
            </marc:subfield>
          </xsl:if>
          <xsl:if test="@type!='conference'">
            <marc:subfield code="e">
              <!-- TODO add labels to modsenhancer/relacode (update) ('issuing body' for 'isb' and 'host institution' for 'his') -->
              <xsl:choose>
                <xsl:when test="../mods:roleTerm[@type='code']='isb'">
                  <xsl:value-of select="'issuing body'" />
                </xsl:when>
                <xsl:when test="../mods:roleTerm[@type='code']='his'">
                  <xsl:value-of select="'host institution'" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="mods:role/mods:roleTerm[@type='text']" />
                </xsl:otherwise>
              </xsl:choose>
            </marc:subfield>
          </xsl:if>
          <marc:subfield code="4">
            <xsl:value-of select="mods:role/mods:roleTerm[@type='code']" />
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:relatedItem[not(@type)]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'787'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='preceding']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'780'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- use definded query for succeeding (see above) -->
  <xsl:template match="mods:mods" mode="succeeding">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'785'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='otherVersion']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'775'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='otherFormat']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'776'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='original']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'534'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='host']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'773'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:for-each select="@displaylabel">
          <marc:subfield code="3">
            <xsl:value-of select="." />
          </marc:subfield>
        </xsl:for-each>
        <!-- v3 part/text -->
        <xsl:for-each select="mods:part/mods:text">
          <marc:subfield code="g">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
        <!-- v3 sici part/detail 773$q 	1:2:3<4-->
        <xsl:if test="mods:part/mods:detail">
          <xsl:variable name="parts">
            <xsl:for-each select="mods:part/mods:detail">
              <xsl:value-of select="concat(mods:number,':')" />
            </xsl:for-each>
          </xsl:variable>
          <marc:subfield code="q">
            <xsl:choose>
              <xsl:when test="mods:part/mods:extent/mods:start">
                <xsl:value-of
                    select="concat(substring($parts,1,string-length($parts)-1),'&lt;',mods:part/mods:extent/mods:start)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="substring($parts,1,string-length($parts)-1)" />
              </xsl:otherwise>
            </xsl:choose>
          </marc:subfield>
        </xsl:if>
        <xsl:if test="mods:titleInfo[@type='abbreviated']">
          <marc:subfield code="p">
            <xsl:for-each select="mods:titleInfo[@type='abbreviated']/mods:title">
              <xsl:if test="position() != 1">
                <xsl:value-of select="', '" />
              </xsl:if>
              <xsl:value-of select="." />
            </xsl:for-each>
          </marc:subfield>
        </xsl:if>
        <xsl:call-template name="relatedItem76X-78X" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- use definded query for constituent (see above) -->
  <xsl:template match="mods:mods" mode="constituent">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:value-of select="'774'" />
      </xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="'0'" />
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="relatedItem76X-78X">
    <xsl:call-template name="relatedItemNames" />
    <xsl:for-each select="mods:titleInfo">
      <xsl:for-each select="mods:title">
        <xsl:choose>
          <xsl:when test="not(ancestor-or-self::mods:titleInfo/@type)">
            <marc:subfield code="t">
              <xsl:value-of select="." />
            </marc:subfield>
          </xsl:when>
          <xsl:when test="ancestor-or-self::mods:titleInfo/@type='uniform'">
            <marc:subfield code="s">
              <xsl:value-of select="." />
            </marc:subfield>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
      <xsl:for-each select="mods:partNumber">
        <marc:subfield code="g">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:for-each>
      <xsl:for-each select="mods:partName">
        <marc:subfield code="g">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:if test="@type!='original'">
      <xsl:for-each select="mods:physicalDescription/mods:extent">
        <marc:subfield code="h">
          <xsl:value-of select="." />
        </marc:subfield>
      </xsl:for-each>
    </xsl:if>
    <xsl:for-each select="@displayLabel">
      <marc:subfield code="i">
        <xsl:value-of select="." />
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:identifier[not(@type)]">
      <marc:subfield code="o">
        <xsl:value-of select="." />
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:identifier[@type='issn']">
      <marc:subfield code="x">
        <xsl:value-of select="." />
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:identifier[@type='isbn']">
      <marc:subfield code="z">
        <xsl:value-of select="." />
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:identifier[@type='local']|@xlink:href|@ID">
      <marc:subfield code="w">
        <xsl:value-of select="." />
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:note">
      <marc:subfield code="n">
        <xsl:value-of select="." />
      </marc:subfield>
    </xsl:for-each>
  </xsl:template>

  <!-- subfield a contains only names, no additional role terms -->
  <xsl:template name="relatedItemNames">
    <xsl:if test="mods:name">
      <marc:subfield code="a">
        <xsl:for-each select="mods:name">
          <xsl:choose>
            <xsl:when test="mods:displayForm">
              <xsl:for-each select="mods:displayForm">
                <xsl:if test="position() != 1">
                  <xsl:value-of select="' '" />
                </xsl:if>
                <xsl:value-of select="." />
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="@authorityURI and @valueURI">
              <xsl:for-each select="mcrmods:to-mycoreclass(., 'parent')//category">
                <xsl:if test="position() != 1">
                  <xsl:value-of select="', '" />
                </xsl:if>
                <xsl:choose>
                  <xsl:when test="label[lang('en')]">
                    <xsl:value-of select="label[lang('en')]/@text" />
                  </xsl:when>
                  <xsl:when test="label[lang($DefaultLang)]">
                    <xsl:value-of select="label[lang($DefaultLang)]/@text" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="label[1]/@text" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="nameString">
                <xsl:for-each select="mods:name">
                  <xsl:value-of select="mods:namePart[1][not(@type='date')]" />
                  <xsl:if test="mods:namePart[position()&gt;1][@type='date']">
                    <xsl:value-of select="concat(' ',mods:namePart[position()&gt;1][@type='date'])" />
                  </xsl:if>
                </xsl:for-each>
              </xsl:variable>
              <xsl:value-of select="substring($nameString, 1,string-length($nameString)-2)" />
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="position()!=last()">
            <xsl:value-of select="'; '" />
          </xsl:if>
        </xsl:for-each>
      </marc:subfield>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

    <!-- Übersicht der Änderungen:
    - 001: MODS ID übernommen (für K10+ Zentral)
    - 024: Ersten Indikator gleich 7 gesetzt (in Feld 2 Quelle angegeben)
    - 041: Ersten Indikator unbesetzt lassen
    - 041: Bezeichnungen für Sprachen aufgelöst auf internationale Kürzel
    - 050: Zweiten Indikator gleich '4' gesetzt falls andere Quelle als LoC
    - 084: andere Klassifikationen eingearbeitet (z.B. sdnb, rvk, bkl)
    - 084: Indikatoren gleich ' ' gesetzt
    - 100/700: templates zusammengelegt
    - 100/700: in subfield a displayForm eingetragen
    - 110/710: templates zusammengelegt
    - 110/710: in subfield a mods:namePart bzw. mods:displayForm als Varianten eingetragen
    - 100/110/111/700/710/711: match geändert, Abgleich mit Klassifikation der roleTerms um ersten geistigen Schöpfer zu finden
    - 100/110/111/700/710/711: gnd-Verknüpfung im subfield 0 mit Source Code DE-588 (gnd) davorgestellt
    - 111/711: templates zusammengelegt
    - 242: stmtOfResponsiblity hinzugefügt
    - 245: mods:nonSort ein zusätzliches Leerzeichen eingefügt und zweiten Indikator in Titelfelden verbessert (130, 630, 730, 240, 242, 245)
    - 245: Subfield c mit geistigem Schöpfer und weiteren beteiligten Personen und herausgebenden Institutionen besetzt falls kein mods:note[@type='statement of responsibility'] vorhanden ist (keine Besetzung mit Reviewer, Publisher und Distributor)
    - 260: Angaben in subfield g in Klammern gesetzt
    - 260/264: subfield c korrigiert für die jeweiligen Varianten (Datum, nur start, start und end)
    - 264: @eventType als Kriterium für Indikatoren und Feld 264 festgelegt
    - 336/655/047: templates aufgespalten (drei templates statt nur eines)
    - 336: subfield a und 2 abgeändert, Codierung für subfield b definiert
    - 337/338: Felder hinzugefügt
    - 490: Feld 490 mit series statement besetzt statt Feld 440 (2008 abgeschafft)
    - 490: Ersten Indikator gleich 0 gesetzt (series not traced)
    - 506: 'restrictionOnAccess' umbenannt in 'embargo'
    - 520: CR und NL gelöscht
    - 650/651: für topical, temporal und geographic terms jeweils ein template für lcsh, lcshac, mesh, csh, nal, rvm definiert und eines für restliche Varianten (gnd, stw, ohne @authority etc.),
             Indikatoren abhängig von authority definiert, Quelle in subfield 2 vorhanden für alle außer durch Indikatoren definierte Varianten,
           bei lcsh erstes Schlagwort in subfield a, folgende in subfields x, y und z,
           für andere Regelwerke Schlagwörter je in einem subfield a
    - 655: 655 Zweiten Indikator gleich 4 gesetzt (source not specified)
    - 76X-78X: Auftrennung des templates z.T. auf Einzelfelder, zusätzliches choose für subfield q eingefügt
    - 773: Reihenfolge der subfields angepasst (a, t, g, q, w, n)
    - 810: Ersten Indikator gleich 1 bzw. 2 gesetzt (Unterscheidung ob personal, corporate, meeting)
    - 510/774/784: query for relatedItem host,series -> constituent, preceding -> succeeding, references -> isReferencedBy
    - 773: Subfiels g alle Angaben zu einem Feld zusammengefügt
    - template "RelatedItemNames" bearbeitet sodass vollständige Bezeichnunge (displayForm) übernommen werden
    -->

    <!-- TODO
    - add labels to modsenhancer/relacode (update) ('issuing body' for 'isb' and 'host institution' for 'his') (fields 110/710/810) -> danach entsprechenden Code in templates löschen (vorläufig als Ersatz eingefügt)
    -->
