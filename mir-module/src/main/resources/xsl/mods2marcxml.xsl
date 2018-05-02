<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="mods xlink"
                xmlns:marc="http://www.loc.gov/MARC21/slim">
  <!--
    Version 2.0 - 2012/05/11 WS
    Upgraded stylesheet to XSLT 2.0
    Upgraded to MODS 3.4
    MODS v3 to MARC21Slim transformation  	ntra 2/20/04
  -->

  <xsl:include href="MARC21slimUtils.xsl"/>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:variable name="institutes" select="document('classification:metadata:-1:children:mir_institutes')"/>
  <xsl:variable name="marcrelator" select="document('classification:metadata:-1:children:marcrelator')"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mods:modsCollection">
    <marc:collection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                     xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
      <xsl:apply-templates/>
    </marc:collection>
  </xsl:template>

  <xsl:template match="mods:targetAudience[@authority='marctarget']" mode="ctrl008">
    <xsl:choose>
      <xsl:when test=".='adolescent'">d</xsl:when>
      <xsl:when test=".='adult'">e</xsl:when>
      <xsl:when test=".='general'">g</xsl:when>
      <xsl:when test=".='juvenile'">j</xsl:when>
      <xsl:when test=".='preschool'">a</xsl:when>
      <xsl:when test=".='specialized'">f</xsl:when>
      <xsl:otherwise>
        <xsl:text>|</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:typeOfResource" mode="leader">
    <xsl:choose>
      <xsl:when test="text()='text'">a</xsl:when>
      <xsl:when test="text()='text' and @manuscript='yes'">t</xsl:when>
      <xsl:when test="text()='cartographic' and @manuscript='yes'">f</xsl:when>
      <xsl:when test="text()='cartographic'">e</xsl:when>
      <xsl:when test="text()='notated music' and @manuscript='yes'">d</xsl:when>
      <xsl:when test="text()='notated music'">c</xsl:when>
      <xsl:when test="text()='sound recording-nonmusical'">i</xsl:when>
      <xsl:when test="text()='sound recording'">j</xsl:when>
      <xsl:when test="text()='sound recording-musical'">j</xsl:when>
      <xsl:when test="text()='still image'">k</xsl:when>
      <xsl:when test="text()='moving image'">g</xsl:when>
      <xsl:when test="text()='three dimensional object'">r</xsl:when>
      <xsl:when test="text()='software, multimedia'">m</xsl:when>
      <xsl:when test="text()='mixed material'">p</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:typeOfResource" mode="ctrl008">
    <xsl:choose>
      <xsl:when test="text()='text' and @manuscript='yes'">BK</xsl:when>
      <xsl:when test="text()='text'">
        <xsl:choose>
          <xsl:when test="../mods:originInfo/mods:issuance='monographic'">BK</xsl:when>
          <xsl:when test="../mods:originInfo/mods:issuance='continuing'">SE</xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="text()='cartographic' and @manuscript='yes'">MP</xsl:when>
      <xsl:when test="text()='cartographic'">MP</xsl:when>
      <xsl:when test="text()='notated music' and @manuscript='yes'">MU</xsl:when>
      <xsl:when test="text()='notated music'">MU</xsl:when>
      <xsl:when test="text()='sound recording'">MU</xsl:when>
      <xsl:when test="text()='sound recording-nonmusical'">MU</xsl:when>
      <xsl:when test="text()='sound recording-musical'">MU</xsl:when>
      <xsl:when test="text()='still image'">VM</xsl:when>
      <xsl:when test="text()='moving image'">VM</xsl:when>
      <xsl:when test="text()='three dimensional object'">VM</xsl:when>
      <xsl:when test="text()='software, multimedia'">CF</xsl:when>
      <xsl:when test="text()='mixed material'">MM</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="controlField008-24-27">
    <xsl:variable name="chars">
      <xsl:for-each select="mods:genre[@authority='marc']">
        <xsl:choose>
          <xsl:when test=".='abstract of summary'">a</xsl:when>
          <xsl:when test=".='bibliography'">b</xsl:when>
          <xsl:when test=".='catalog'">c</xsl:when>
          <xsl:when test=".='dictionary'">d</xsl:when>
          <xsl:when test=".='directory'">r</xsl:when>
          <xsl:when test=".='discography'">k</xsl:when>
          <xsl:when test=".='encyclopedia'">e</xsl:when>
          <xsl:when test=".='filmography'">q</xsl:when>
          <xsl:when test=".='handbook'">f</xsl:when>
          <xsl:when test=".='index'">i</xsl:when>
          <xsl:when test=".='law report or digest'">w</xsl:when>
          <xsl:when test=".='legal article'">g</xsl:when>
          <xsl:when test=".='legal case and case notes'">v</xsl:when>
          <xsl:when test=".='legislation'">l</xsl:when>
          <xsl:when test=".='patent'">j</xsl:when>
          <xsl:when test=".='programmed text'">p</xsl:when>
          <xsl:when test=".='review'">o</xsl:when>
          <xsl:when test=".='statistics'">s</xsl:when>
          <xsl:when test=".='survey of literature'">n</xsl:when>
          <xsl:when test=".='technical report'">t</xsl:when>
          <xsl:when test=".='theses'">m</xsl:when>
          <xsl:when test=".='treaty'">z</xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="makeSize">
      <xsl:with-param name="string" select="$chars"/>
      <xsl:with-param name="length" select="4"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="controlField008-30-31">
    <xsl:variable name="chars">
      <xsl:for-each select="mods:genre[@authority='marc']">
        <xsl:choose>
          <xsl:when test=".='biography'">b</xsl:when>
          <xsl:when test=".='conference publication'">c</xsl:when>
          <xsl:when test=".='drama'">d</xsl:when>
          <xsl:when test=".='essay'">e</xsl:when>
          <xsl:when test=".='fiction'">f</xsl:when>
          <xsl:when test=".='folktale'">o</xsl:when>
          <xsl:when test=".='history'">h</xsl:when>
          <xsl:when test=".='humor, satire'">k</xsl:when>
          <xsl:when test=".='instruction'">i</xsl:when>
          <xsl:when test=".='interview'">t</xsl:when>
          <xsl:when test=".='language instruction'">j</xsl:when>
          <xsl:when test=".='memoir'">m</xsl:when>
          <xsl:when test=".='rehersal'">r</xsl:when>
          <xsl:when test=".='reporting'">g</xsl:when>
          <xsl:when test=".='sound'">s</xsl:when>
          <xsl:when test=".='speech'">l</xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="makeSize">
      <xsl:with-param name="string" select="$chars"/>
      <xsl:with-param name="length" select="2"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="makeSize">
    <xsl:param name="string"/>
    <xsl:param name="length"/>
    <xsl:variable name="nstring" select="normalize-space($string)"/>
    <xsl:variable name="nstringlength" select="string-length($nstring)"/>
    <xsl:choose>
      <xsl:when test="$nstringlength&gt;$length">
        <xsl:value-of select="substring($nstring,1,$length)"/>
      </xsl:when>
      <xsl:when test="$nstringlength&lt;$length">
        <xsl:value-of select="$nstring"/>
        <xsl:call-template name="buildSpaces">
          <xsl:with-param name="spaces" select="$length - $nstringlength"/>
          <xsl:with-param name="char">|</xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nstring"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:mods">
    <marc:record>
      <marc:leader>
        <!-- 00-04 -->
        <xsl:text>     </xsl:text>
        <!-- 05 -->
        <xsl:text>n</xsl:text>
        <!-- 06 -->
        <xsl:apply-templates mode="leader" select="mods:typeOfResource[1]"/>
        <!-- 07 -->
        <xsl:choose>
          <xsl:when test="mods:originInfo/mods:issuance='monographic'">m</xsl:when>
          <xsl:when test="mods:originInfo/mods:issuance='continuing'">s</xsl:when>
          <xsl:when test="mods:typeOfResource/@collection='yes'">c</xsl:when>
          <xsl:when test="mods:originInfo/mods:issuance='multipart monograph'">m</xsl:when>
          <xsl:when test="mods:originInfo/mods:issuance='single unit'">m</xsl:when>
          <xsl:when test="mods:originInfo/mods:issuance='integrating resource'">i</xsl:when>
          <xsl:when test="mods:originInfo/mods:issuance='serial'">s</xsl:when>
          <xsl:otherwise>m</xsl:otherwise>
        </xsl:choose>
        <!-- 08 -->
        <xsl:text> </xsl:text>
        <!-- 09 -->
        <xsl:text> </xsl:text>
        <!-- 10 -->
        <xsl:text>2</xsl:text>
        <!-- 11 -->
        <xsl:text>2</xsl:text>
        <!-- 12-16 -->
        <xsl:text>     </xsl:text>
        <!-- 17 -->
        <xsl:text>u</xsl:text>
        <!-- 18 -->
        <xsl:text>u</xsl:text>
        <!-- 19 -->
        <xsl:text> </xsl:text>
        <!-- 20-23 -->
        <xsl:text>4500</xsl:text>
      </marc:leader>
      <xsl:call-template name="controlRecordInfo"/>
      <xsl:if test="mods:genre[@authority='marc']='atlas'">
        <marc:controlfield tag="007">ad||||||</marc:controlfield>
      </xsl:if>
      <xsl:if test="mods:genre[@authority='marc']='model'">
        <marc:controlfield tag="007">aq||||||</marc:controlfield>
      </xsl:if>
      <xsl:if test="mods:genre[@authority='marc']='remote sensing image'">
        <marc:controlfield tag="007">ar||||||</marc:controlfield>
      </xsl:if>
      <xsl:if test="mods:genre[@authority='marc']='map'">
        <marc:controlfield tag="007">aj||||||</marc:controlfield>
      </xsl:if>
      <xsl:if test="mods:genre[@authority='marc']='globe'">
        <marc:controlfield tag="007">d|||||</marc:controlfield>
      </xsl:if>
      <marc:controlfield tag="008">
        <xsl:variable name="typeOf008">
          <xsl:apply-templates mode="ctrl008" select="mods:typeOfResource"/>
        </xsl:variable>
        <!-- 00-05 -->
        <xsl:choose>
          <xsl:when test="mods:recordInfo/mods:recordContentSource[@authority='marcorg']">
            <xsl:value-of select="mods:recordInfo/mods:recordCreationDate[@encoding='marc']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>      </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <!-- 06 -->
        <xsl:choose>
          <xsl:when test="mods:originInfo/mods:issuance='monographic' and count(mods:originInfo/mods:dateIssued)=1">s
          </xsl:when>
          <xsl:when test="mods:originInfo/mods:dateIssued[@qualifier='questionable']">q</xsl:when>
          <xsl:when
              test="mods:originInfo/mods:issuance='monographic' and mods:originInfo/mods:dateIssued[@point='start'] and mods:originInfo/mods:dateIssued[@point='end']">
            m
          </xsl:when>
          <xsl:when
              test="mods:originInfo/mods:issuance='continuing' and mods:originInfo/mods:dateIssued[@point='end' and @encoding='marc']='9999'">
            c
          </xsl:when>
          <xsl:when
              test="mods:originInfo/mods:issuance='continuing' and mods:originInfo/mods:dateIssued[@point='end' and @encoding='marc']='uuuu'">
            u
          </xsl:when>
          <xsl:when
              test="mods:originInfo/mods:issuance='continuing' and mods:originInfo/mods:dateIssued[@point='end' and @encoding='marc']">
            d
          </xsl:when>
          <xsl:when test="not(mods:originInfo/mods:issuance) and mods:originInfo/mods:dateIssued">s</xsl:when>
          <xsl:when test="mods:originInfo/mods:copyrightDate">s</xsl:when>
          <xsl:otherwise>|</xsl:otherwise>
        </xsl:choose>
        <!-- 07-14 -->
        <!-- 07-10 -->
        <xsl:choose>
          <xsl:when test="mods:originInfo/mods:dateIssued[@point='start' and @encoding='marc']">
            <xsl:value-of select="mods:originInfo/mods:dateIssued[@point='start' and @encoding='marc']"/>
          </xsl:when>
          <xsl:when test="mods:originInfo/mods:dateIssued[@encoding='marc']">
            <xsl:value-of select="mods:originInfo/mods:dateIssued[@encoding='marc']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>    </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <!-- 11-14 -->
        <xsl:choose>
          <xsl:when test="mods:originInfo/mods:dateIssued[@point='end' and @encoding='marc']">
            <xsl:value-of select="mods:originInfo/mods:dateIssued[@point='end' and @encoding='marc']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>    </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <!-- 15-17 -->
        <xsl:choose>
          <xsl:when test="mods:originInfo/mods:place/mods:placeTerm[@type='code'][@authority='marccountry']">
            <xsl:value-of select="mods:originInfo/mods:place/mods:placeTerm[@type='code'][@authority='marccountry']"/>
            <xsl:if
                test="string-length(mods:originInfo/mods:place/mods:placeTerm[@type='code'][@authority='marccountry'])=2">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>   </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <!-- 18-20 -->
        <xsl:text>|||</xsl:text>
        <!-- 21 -->
        <xsl:choose>
          <xsl:when test="$typeOf008='SE'">
            <xsl:choose>
              <xsl:when test="mods:genre[@authority='marc']='database'">d</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='loose-leaf'">l</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='newspaper'">n</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='periodical'">p</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='series'">m</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='web site'">w</xsl:when>
              <xsl:otherwise>|</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>|</xsl:otherwise>
        </xsl:choose>
        <!-- 22 -->
        <xsl:choose>
          <xsl:when test="mods:targetAudience[@authority='marctarget']">
            <xsl:apply-templates mode="ctrl008" select="mods:targetAudience[@authority='marctarget']"/>
          </xsl:when>
          <xsl:otherwise>|</xsl:otherwise>
        </xsl:choose>
        <!-- 23 -->
        <xsl:choose>
          <xsl:when test="$typeOf008='BK' or $typeOf008='MU' or $typeOf008='SE' or $typeOf008='MM'">
            <xsl:choose>
              <xsl:when test="mods:physicalDescription/mods:form[@authority='marcform']='braille'">f</xsl:when>
              <xsl:when test="mods:physicalDescription/mods:form[@authority='marcform']='electronic'">s</xsl:when>
              <xsl:when test="mods:physicalDescription/mods:form[@authority='marcform']='microfiche'">b</xsl:when>
              <xsl:when test="mods:physicalDescription/mods:form[@authority='marcform']='microfilm'">a</xsl:when>
              <xsl:when test="mods:physicalDescription/mods:form[@authority='marcform']='print'">
                <xsl:text> </xsl:text>
              </xsl:when>
              <xsl:otherwise>|</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>|</xsl:otherwise>
        </xsl:choose>
        <!-- 24-27 -->
        <xsl:choose>
          <xsl:when test="$typeOf008='BK'">
            <xsl:call-template name="controlField008-24-27"/>
          </xsl:when>
          <xsl:when test="$typeOf008='MP'">
            <xsl:text>|</xsl:text>
            <xsl:choose>
              <xsl:when test="mods:genre[@authority='marc']='atlas'">e</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='globe'">d</xsl:when>
              <xsl:otherwise>|</xsl:otherwise>
            </xsl:choose>
            <xsl:text>||</xsl:text>
          </xsl:when>
          <xsl:when test="$typeOf008='CF'">
            <xsl:text>||</xsl:text>
            <xsl:choose>
              <xsl:when test="mods:genre[@authority='marc']='database'">e</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='font'">f</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='game'">g</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='numerical data'">a</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='sound'">h</xsl:when>
              <xsl:otherwise>|</xsl:otherwise>
            </xsl:choose>
            <xsl:text>|</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>||||</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <!-- 28 -->
        <xsl:text>|</xsl:text>
        <!-- 29 -->
        <xsl:choose>
          <xsl:when test="$typeOf008='BK' or $typeOf008='SE'">
            <xsl:choose>
              <xsl:when test="mods:genre[@authority='marc']='conference publication'">1</xsl:when>
              <xsl:otherwise>|</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$typeOf008='MP' or $typeOf008='VM'">
            <xsl:choose>
              <xsl:when test="mods:physicalDescription/mods:form='braille'">f</xsl:when>
              <xsl:when test="mods:physicalDescription/mods:form='electronic'">m</xsl:when>
              <xsl:when test="mods:physicalDescription/mods:form='microfiche'">b</xsl:when>
              <xsl:when test="mods:physicalDescription/mods:form='microfilm'">a</xsl:when>
              <xsl:when test="mods:physicalDescription/mods:form='print'">
                <xsl:text> </xsl:text>
              </xsl:when>
              <xsl:otherwise>|</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>|</xsl:otherwise>
        </xsl:choose>
        <!-- 30-31 -->
        <xsl:choose>
          <xsl:when test="$typeOf008='MU'">
            <xsl:call-template name="controlField008-30-31"/>
          </xsl:when>
          <xsl:when test="$typeOf008='BK'">
            <xsl:choose>
              <xsl:when test="mods:genre[@authority='marc']='festschrift'">1</xsl:when>
              <xsl:otherwise>|</xsl:otherwise>
            </xsl:choose>
            <xsl:text>|</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>||</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <!-- 32 -->
        <xsl:text>|</xsl:text>
        <!-- 33 -->
        <xsl:choose>
          <xsl:when test="$typeOf008='VM'">
            <xsl:choose>
              <xsl:when test="mods:genre[@authority='marc']='art originial'">a</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='art reproduction'">c</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='chart'">n</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='diorama'">d</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='filmstrip'">f</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='flash card'">o</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='graphic'">k</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='kit'">b</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='technical drawing'">l</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='slide'">s</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='realia'">r</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='picture'">i</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='motion picture'">m</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='model'">q</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='microscope slide'">p</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='toy'">w</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='transparency'">t</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='videorecording'">v</xsl:when>
              <xsl:otherwise>|</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$typeOf008='BK'">
            <xsl:choose>
              <xsl:when test="mods:genre[@authority='marc']='comic strip'">c</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='fiction'">1</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='essay'">e</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='drama'">d</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='humor, satire'">h</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='letter'">i</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='novel'">f</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='short story'">j</xsl:when>
              <xsl:when test="mods:genre[@authority='marc']='speech'">s</xsl:when>
              <xsl:otherwise>|</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>|</xsl:otherwise>
        </xsl:choose>
        <!-- 34 -->
        <xsl:choose>
          <xsl:when test="$typeOf008='BK'">
            <xsl:choose>
              <xsl:when test="mods:genre[@authority='marc']='biography'">d</xsl:when>
              <xsl:otherwise>|</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>|</xsl:otherwise>
        </xsl:choose>
        <!-- 35-37 -->
        <xsl:choose>
          <xsl:when test="mods:language/mods:languageTerm[@authority='iso639-2b']">
            <xsl:value-of select="mods:language/mods:languageTerm[@authority='iso639-2b']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>|||</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <!-- 38-39 -->
        <xsl:text>||</xsl:text>
      </marc:controlfield>
      <xsl:call-template name="source"/>
      <xsl:apply-templates/>
      <xsl:if test="mods:classification[@authority='lcc']">
        <xsl:call-template name="lcClassification"/>
      </xsl:if>
      <!-- query for relatedItem host,series -> constituent, preceding -> succeeding, references -> isReferencedBy -->
      <xsl:variable name="mcrId" select="@ID"/>
      <xsl:variable name="constituent"
                    select="document(concat('solr:q=%2B(mods.relatedItem.host%3A',$mcrId,'+mods.relatedItem.series%3A',$mcrId,')+%2BobjectType%3Amods&amp;fl=returnId&amp;rows=10000&amp;wt=xml'))/response/result/doc/str[@name='returnId']"/>
      <xsl:for-each select="$constituent">
        <xsl:variable name="constituentId" select="text()"/>
        <xsl:variable name="constituentMods"
                      select="document(concat('xslTransform:mods:mcrobject:',$constituentId))/mods:mods"/>
        <xsl:apply-templates select="$constituentMods" mode="constituent"/>
      </xsl:for-each>
      <xsl:variable name="succeeding"
                    select="document(concat('solr:q=%2Bmods.relatedItem.preceding%3A',$mcrId,'+%2BobjectType%3Amods&amp;fl=returnId&amp;rows=10000&amp;wt=xml'))/response/result/doc/str[@name='returnId']"/>
      <xsl:for-each select="$succeeding">
        <xsl:variable name="succeedingId" select="text()"/>
        <xsl:variable name="succeedingMods"
                      select="document(concat('xslTransform:mods:mcrobject:',$succeedingId))/mods:mods"/>
        <xsl:apply-templates select="$succeedingMods" mode="succeeding"/>
      </xsl:for-each>
      <xsl:variable name="isReferencedBy"
                    select="document(concat('solr:q=%2Bmods.relatedItem.references%3A',$mcrId,'+%2BobjectType%3Amods&amp;fl=returnId&amp;rows=10000&amp;wt=xml'))/response/result/doc/str[@name='returnId']"/>
      <xsl:for-each select="$isReferencedBy">
        <xsl:variable name="isReferencedById" select="text()"/>
        <xsl:variable name="isReferencedByMods"
                      select="document(concat('xslTransform:mods:mcrobject:',$isReferencedById))/mods:mods"/>
        <xsl:apply-templates select="$isReferencedByMods" mode="isReferencedBy"/>
      </xsl:for-each>
      <!-- add field 337 media type -->
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">337</xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="a">
            <xsl:text>Computermedien</xsl:text>
          </marc:subfield>
          <marc:subfield code="b">
            <xsl:text>c</xsl:text>
          </marc:subfield>
          <marc:subfield code="2">
            <xsl:text>rdamedia</xsl:text>
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
      <!-- add field 338 carrier type -->
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">338</xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="a">
            <xsl:text>Online-Ressource</xsl:text>
          </marc:subfield>
          <marc:subfield code="b">
            <xsl:text>cr</xsl:text>
          </marc:subfield>
          <marc:subfield code="2">
            <xsl:text>rdacarrier</xsl:text>
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </marc:record>
  </xsl:template>

  <xsl:template match="*"/>

  <!-- Title Info elements -->
  <xsl:template match="mods:titleInfo[not(ancestor-or-self::mods:subject)][not(@type)][1]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">245</xsl:with-param>
      <xsl:with-param name="ind1">1</xsl:with-param>
      <!-- add additional space -->
      <xsl:with-param name="ind2" select="string-length(mods:nonSort)+1"/>
      <xsl:with-param name="subfields">
        <xsl:call-template name="titleInfo"/>
        <xsl:call-template name="stmtOfResponsibility"/>
        <xsl:call-template name="form"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:titleInfo[@type='abbreviated']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">210</xsl:with-param>
      <xsl:with-param name="ind1">1</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="titleInfo"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:titleInfo[@type='translated']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">242</xsl:with-param>
      <xsl:with-param name="ind1">1</xsl:with-param>
      <!-- add additional space -->
      <xsl:with-param name="ind2" select="string-length(mods:nonSort)+1"/>
      <xsl:with-param name="subfields">
        <xsl:call-template name="titleInfo"/>
        <!-- add statement of responsibility -->
        <xsl:call-template name="stmtOfResponsibility"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:titleInfo[@type='alternative']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">246</xsl:with-param>
      <xsl:with-param name="ind1">3</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="titleInfo"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:titleInfo[@type='uniform'][1]">
    <xsl:choose>
      <xsl:when
          test="../mods:name/mods:role/mods:roleTerm[@type='text']='creator' or mods:name/mods:role/mods:roleTerm[@type='code']='cre'">
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">240</xsl:with-param>
          <xsl:with-param name="ind1">1</xsl:with-param>
          <!-- add additional space -->
          <xsl:with-param name="ind2" select="string-length(mods:nonSort)+1"/>
          <xsl:with-param name="subfields">
            <xsl:call-template name="titleInfo"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">130</xsl:with-param>
          <!-- add additional space -->
          <xsl:with-param name="ind1" select="string-length(mods:nonSort)+1"/>
          <xsl:with-param name="subfields">
            <xsl:call-template name="titleInfo"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:titleInfo[@type='uniform'][position()>1]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">730</xsl:with-param>
      <!-- add additional space -->
      <xsl:with-param name="ind1" select="string-length(mods:nonSort)+1"/>
      <xsl:with-param name="subfields">
        <xsl:call-template name="titleInfo"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:titleInfo[not(ancestor-or-self::mods:subject)][not(@type)][position()>1]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">246</xsl:with-param>
      <xsl:with-param name="ind1">3</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="titleInfo"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Name elements -->
  <xsl:template match="mods:name">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">720</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="mods:namePart"/>
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
          <xsl:with-param name="tag">100</xsl:with-param>
          <xsl:with-param name="ind1">1</xsl:with-param>
          <xsl:with-param name="subfields">
            <!-- show mods:displayForm in subfield a -->
            <marc:subfield code="a">
              <xsl:value-of select="mods:displayForm"/>
            </marc:subfield>
            <xsl:for-each select="mods:namePart[@type='termsOfAddress']">
              <marc:subfield code="c">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:namePart[@type='date']">
              <marc:subfield code="d">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='text']">
              <marc:subfield code="e">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
              <marc:subfield code="4">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:affiliation">
              <marc:subfield code="u">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:description">
              <marc:subfield code="g">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <!-- add identifier and gnd as source -->
            <xsl:for-each select="mods:nameIdentifier[@type='gnd']">
              <marc:subfield code="0">
                <xsl:choose>
                  <xsl:when test="contains(.,'(DE-588)')">
                    <xsl:value-of select="."/>
                  </xsl:when>
                  <xsl:when test="contains(.,'(DE-601)')">
                    <xsl:value-of select="."/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('(DE-588)',.)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">700</xsl:with-param>
          <xsl:with-param name="ind1">1</xsl:with-param>
          <xsl:with-param name="subfields">
            <!-- show mods:displayForm in subfield a -->
            <marc:subfield code="a">
              <xsl:value-of select="mods:displayForm"/>
            </marc:subfield>
            <xsl:for-each select="mods:namePart[@type='termsOfAddress']">
              <marc:subfield code="c">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:namePart[@type='date']">
              <marc:subfield code="d">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='text']">
              <marc:subfield code="e">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
              <marc:subfield code="4">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:affiliation">
              <marc:subfield code="u">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <!-- add identifier and gnd as source -->
            <xsl:for-each select="mods:nameIdentifier[@type='gnd']">
              <marc:subfield code="0">
                <xsl:choose>
                  <xsl:when test="contains(.,'(DE-588)')">
                    <xsl:value-of select="."/>
                  </xsl:when>
                  <xsl:when test="contains(.,'(DE-601)')">
                    <xsl:value-of select="."/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('(DE-588)',.)"/>
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
          <xsl:with-param name="tag">110</xsl:with-param>
          <xsl:with-param name="ind1">2</xsl:with-param>
          <xsl:with-param name="subfields">
            <!-- show mods:displayForm in subfield a -->
            <marc:subfield code="a">
              <xsl:choose>
                <!-- if university. institute is given -->
                <xsl:when test="contains(mods:displayForm,'.')">
                  <xsl:value-of select="substring-before(mods:displayForm,'.')"/>
                </xsl:when>
                <!-- if institution nameParts are given -->
                <xsl:when test="mods:namePart">
                  <xsl:value-of select="mods:namePart[1]"/>
                </xsl:when>
                <!-- if only whole institution name is given -->
                <xsl:when test="mods:displayForm">
                  <xsl:value-of select="mods:displayForm"/>
                </xsl:when>
                <!-- if no institution name is given, but @valueURI is present -->
                <!-- TODO resolve @valueURI locally (names of institution and universites) -->
                <xsl:when test="@valueURI">
                  <xsl:variable name="categId" select="substring-after(@valueURI, '#')"/>
                  <xsl:variable name="institute" select="$institutes//category[@ID=$categId]"/>
                  <xsl:apply-templates select="$institute" mode="name110-710-810-1"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="mods:displayForm"/>
                </xsl:otherwise>
              </xsl:choose>
            </marc:subfield>
            <marc:subfield code="b">
              <xsl:choose>
                <!-- if university.institute is given -->
                <xsl:when test="contains(mods:displayForm,'.')">
                  <xsl:value-of select="substring-after(mods:displayForm,'. ')"/>
                </xsl:when>
                <!-- if institution nameParts are given -->
                <xsl:when test="mods:namePart">
                  <xsl:value-of select="mods:namePart[position()>1]"/>
                </xsl:when>
                <!-- if only whole institution name is given (whole name in subfield a, subfield b is empty) -->
                <xsl:when test="mods:displayForm"/>
                <!-- if no institution name is given, but @valueURI is present -->
                <!-- TODO resolve @valueURI locally (names of institution and universites) -->
                <xsl:when test="@valueURI">
                  <xsl:variable name="categId" select="substring-after(@valueURI, '#')"/>
                  <xsl:variable name="institute" select="$institutes//category[@ID=$categId]"/>
                  <xsl:apply-templates select="$institute" mode="name110-710-810-2"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="mods:namePart[position()>1]"/>
                </xsl:otherwise>
              </xsl:choose>
            </marc:subfield>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='text']">
              <marc:subfield code="e">
                <!-- TODO add labels to modsenhancer/relacode (update) ('issuing body' for 'isb' and 'host institution' for 'his') -->
                <xsl:choose>
                  <xsl:when test="../mods:roleTerm[@type='code']='isb'">issuing body</xsl:when>
                  <xsl:when test="../mods:roleTerm[@type='code']='his'">host institution</xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="."/>
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
              <marc:subfield code="4">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:description">
              <marc:subfield code="g">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <!-- add identifier and gnd as source -->
            <xsl:for-each select="mods:nameIdentifier[@type='gnd']">
              <marc:subfield code="0">
                <xsl:choose>
                  <xsl:when test="contains(.,'(DE-588)')">
                    <xsl:value-of select="."/>
                  </xsl:when>
                  <xsl:when test="contains(.,'(DE-601)')">
                    <xsl:value-of select="."/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('(DE-588)',.)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">710</xsl:with-param>
          <xsl:with-param name="ind1">2</xsl:with-param>
          <xsl:with-param name="subfields">
            <!-- show mods:displayForm in subfield a -->
            <marc:subfield code="a">
              <xsl:choose>
                <!-- if university. institute is given -->
                <xsl:when test="contains(mods:displayForm,'.')">
                  <xsl:value-of select="substring-before(mods:displayForm,'.')"/>
                </xsl:when>
                <!-- if institution nameParts are given -->
                <xsl:when test="mods:namePart">
                  <xsl:value-of select="mods:namePart[1]"/>
                </xsl:when>
                <!-- if only whole institution name is given -->
                <xsl:when test="mods:displayForm">
                  <xsl:value-of select="mods:displayForm"/>
                </xsl:when>
                <!-- if no institution name is given, but @valueURI is present -->
                <!-- TODO resolve @valueURI locally (names of institution and universites) -->
                <xsl:when test="@valueURI">
                  <xsl:variable name="categId" select="substring-after(@valueURI, '#')"/>
                  <xsl:variable name="institute" select="$institutes//category[@ID=$categId]"/>
                  <xsl:apply-templates select="$institute" mode="name110-710-810-1"/>
                </xsl:when>
              </xsl:choose>
            </marc:subfield>
            <marc:subfield code="b">
              <xsl:choose>
                <!-- if university.institute is given -->
                <xsl:when test="contains(mods:displayForm,'.')">
                  <xsl:value-of select="substring-after(mods:displayForm,'. ')"/>
                </xsl:when>
                <!-- if institution nameParts are given -->
                <xsl:when test="mods:namePart">
                  <xsl:value-of select="mods:namePart[position()>1]"/>
                </xsl:when>
                <!-- if only whole institution name is given (whole name in subfield a, subfield b is empty) -->
                <xsl:when test="mods:displayForm"/>
                <!-- if no institution name is given, but @valueURI is present -->
                <!-- TODO resolve @valueURI locally (names of institution and universites) -->
                <xsl:when test="@valueURI">
                  <xsl:variable name="categId" select="substring-after(@valueURI, '#')"/>
                  <xsl:variable name="institute" select="$institutes//category[@ID=$categId]"/>
                  <xsl:apply-templates select="$institute" mode="name110-710-810-2"/>
                </xsl:when>
              </xsl:choose>
            </marc:subfield>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='text']">
              <marc:subfield code="e">
                <!-- TODO add labels to modsenhancer/relacode (update) ('issuing body' for 'isb' and 'host institution' for 'his') -->
                <xsl:choose>
                  <xsl:when test="../mods:roleTerm[@type='code']='isb'">issuing body</xsl:when>
                  <xsl:when test="../mods:roleTerm[@type='code']='his'">host institution</xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="."/>
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
              <marc:subfield code="4">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <xsl:for-each select="mods:description">
              <marc:subfield code="g">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <!-- add identifier and gnd as source -->
            <xsl:for-each select="mods:nameIdentifier[@type='gnd']">
              <marc:subfield code="0">
                <xsl:choose>
                  <xsl:when test="contains(.,'(DE-588)')">
                    <xsl:value-of select="."/>
                  </xsl:when>
                  <xsl:when test="contains(.,'(DE-601)')">
                    <xsl:value-of select="."/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('(DE-588)',.)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="category" mode="name110-710-810-1">
    <xsl:if test="ancestor::category">
      <xsl:choose>
        <xsl:when test=".[1]/label[@xml:lang='en']">
          <xsl:value-of select="ancestor::category[1]/label[@xml:lang='en']/@text"/>
        </xsl:when>
        <xsl:when test=".[1]/label[@xml:lang='de']">
          <xsl:value-of select="ancestor::category[1]/label[@xml:lang='de']/@text"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ancestor::category[1]/label[1]/@text"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="category" mode="name110-710-810-2">
    <xsl:choose>
      <xsl:when test="./label[@xml:lang='en']">
        <xsl:value-of select="label[@xml:lang='en']/@text"/>
      </xsl:when>
      <xsl:when test="./label[@xml:lang='de']">
        <xsl:value-of select="label[@xml:lang='de']/@text"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="label[1]/@text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 111 and 711 (main entry / added entry meeting name) in one template -->
  <xsl:template match="mods:name[@type='conference']">
    <xsl:choose>
      <xsl:when
          test="mods:role[mods:roleTerm[@type='code']=$marcrelator//category[@ID='cre']//category/@ID and not(../../mods:name/mods:role/mods:roleTerm[@type='code']='cre' or ../preceding-sibling::mods:name/mods:role[mods:roleTerm[@type='code']=$marcrelator//category[@ID='cre']//category/@ID])]">
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">111</xsl:with-param>
          <xsl:with-param name="ind1">2</xsl:with-param>
          <xsl:with-param name="subfields">
            <marc:subfield code="a">
              <xsl:value-of select="mods:namePart"/>
            </marc:subfield>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
              <marc:subfield code="4">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <!-- add identifier and gnd as source -->
            <xsl:for-each select="mods:nameIdentifier[@type='gnd']">
              <marc:subfield code="0">
                <xsl:choose>
                  <xsl:when test="contains(.,'(DE-588)')">
                    <xsl:value-of select="."/>
                  </xsl:when>
                  <xsl:when test="contains(.,'(DE-601)')">
                    <xsl:value-of select="."/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('(DE-588)',.)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </marc:subfield>
            </xsl:for-each>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="datafield">
          <xsl:with-param name="tag">711</xsl:with-param>
          <xsl:with-param name="ind1">2</xsl:with-param>
          <xsl:with-param name="subfields">
            <marc:subfield code="a">
              <xsl:value-of select="mods:namePart"/>
            </marc:subfield>
            <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
              <marc:subfield code="4">
                <xsl:value-of select="."/>
              </marc:subfield>
            </xsl:for-each>
            <!-- add identifier and gnd as source -->
            <xsl:for-each select="mods:nameIdentifier[@type='gnd']">
              <marc:subfield code="0">
                <xsl:choose>
                  <xsl:when test="contains(.,'(DE-588)')">
                    <xsl:value-of select="."/>
                  </xsl:when>
                  <xsl:when test="contains(.,'(DE-601)')">
                    <xsl:value-of select="."/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('(DE-588)',.)"/>
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
      <xsl:with-param name="tag">047</xsl:with-param>
      <xsl:with-param name="ind2">7</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="."/>
        </marc:subfield>
        <xsl:for-each select="@authority">
          <marc:subfield code='2'>
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:genre[@authority='marcgt' or not(@authority)][1]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">655</xsl:with-param>
      <!-- set second indicator equal to '4' (no source specified) -->
      <xsl:with-param name="ind2">4</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:choose>
          <!-- two different terms-->
          <xsl:when test="../mods:genre[@authority='marcgt'][1]/text()!=../mods:genre[@authority='marcgt'][2]/text()">
            <marc:subfield code="a">
              <xsl:value-of
                  select="concat(../mods:genre[@authority='marcgt'][1],', ',../mods:genre[@authority='marcgt'][2])"/>
            </marc:subfield>
          </xsl:when>
          <!-- one term only -->
          <xsl:otherwise>
            <marc:subfield code="a">
              <xsl:value-of select="../mods:genre[@authority='marcgt'][1]"/>
            </marc:subfield>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- add field 336 content type with coding for subfield b -->
  <xsl:template match="mods:typeOfResource">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">336</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="../mods:typeOfResource"/>
        </marc:subfield>
        <marc:subfield code="b">
          <xsl:choose>
            <xsl:when test="../mods:typeOfResource/text()='text'">
              <xsl:text>txt</xsl:text>
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='cartographic'">
              <xsl:text>crd</xsl:text>
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='notated music'">
              <xsl:text>ntm</xsl:text>
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='sound recording'">
              <xsl:text>prm</xsl:text>
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='sound recording-musical'">
              <xsl:text>prm</xsl:text>
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='sound recording-nonmusical'">
              <xsl:text>snd</xsl:text>
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='still image'">
              <xsl:text>stdi</xsl:text>
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='moving image'">
              <xsl:text>tdi</xsl:text>
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='three dimensional object'">
              <xsl:text>tdf</xsl:text>
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='software, multimedia'">
              <xsl:text>cop</xsl:text>
            </xsl:when>
            <xsl:when test="../mods:typeOfResource/text()='mixed material'">
              <xsl:text>zzz</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>xxx</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </marc:subfield>
        <marc:subfield code="c">
          <xsl:text>rdacontent</xsl:text>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Origin Info elements -->
  <xsl:template match="mods:originInfo">
    <xsl:for-each select="mods:place/mods:placeTerm[@type='code'][@authority='iso3166']">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">044</xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code='c'>
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:if test="mods:dateCaptured[@encoding='iso8601']">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">033</xsl:with-param>
        <xsl:with-param name="ind1">
          <xsl:choose>
            <xsl:when test="mods:dateCaptured[@point='start']|mods:dateCaptured[@point='end']">2</xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="ind2">0</xsl:with-param>
        <xsl:with-param name="subfields">
          <xsl:for-each select="mods:dateCaptured">
            <marc:subfield code='a'>
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="mods:dateModified|mods:dateCreated|mods:dateValid">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">046</xsl:with-param>
        <xsl:with-param name="subfields">
          <xsl:for-each select="mods:dateModified">
            <marc:subfield code='j'>
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:dateCreated[@point='start']|mods:dateCreated[not(@point)]">
            <marc:subfield code='k'>
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:dateCreated[@point='end']">
            <marc:subfield code='l'>
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:dateValid[@point='start']|mods:dateValid[not(@point)]">
            <marc:subfield code='m'>
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:dateValid[@point='end']">
            <marc:subfield code='n'>
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:for-each select="mods:edition">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">250</xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code='a'>
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="mods:frequency">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">310</xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code='a'>
            <xsl:value-of select="."/>
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
              <xsl:value-of select="'264'"/>
            </xsl:when>
            <xsl:otherwise>260</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="ind2">
          <xsl:choose>
            <xsl:when test="@eventType='production'">0</xsl:when>
            <xsl:when test="@eventType='publication'">1</xsl:when>
            <xsl:when test="@eventType='manufacture'">2</xsl:when>
            <xsl:when test="@eventType='distribution'">3</xsl:when>
            <xsl:otherwise>
              <xsl:text> </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <xsl:for-each select="mods:place/mods:placeTerm[@type='text']">
            <marc:subfield code='a'>
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:publisher">
            <marc:subfield code='b'>
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:dateIssued">
            <marc:subfield code='c'>
              <!-- if only one date (neither start  nor end date) is present -->
              <xsl:if test="not(@point)">
                <xsl:value-of select="."/>
              </xsl:if>
              <!-- if start and end dates are present -->
              <xsl:if test="@point='start' and ../mods:dateIssued[@point='end']">
                <xsl:value-of select="concat(../mods:dateIssued[@point='start'],'-',../mods:dateIssued[@point='end'])"/>
              </xsl:if>
              <!-- if only a start date is present -->
              <xsl:if test="@point='start'and not(../mods:dateIssued[@point='end'])">
                <xsl:value-of select="concat(../mods:dateIssued[@point='start'],'-')"/>
              </xsl:if>
              <xsl:if test="@qualifier='questionable'">?</xsl:if>
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="mods:dateCreated">
            <!-- add parentheses -->
            <marc:subfield code='g'>
              <xsl:value-of select="concat('(',.,')')"/>
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
    <xsl:variable name="rfc4646" select="document('http://mycore.de/classifications/rfc4646.xml')"/>
    <xsl:variable name="lang" select="mods:languageTerm"/>
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">041</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:choose>
          <xsl:when test="mods:languageTerm[@objectPart='text/sound track']">
            <marc:subfield code='a'>
              <xsl:value-of select="$rfc4646//category[@ID=$lang]/label[@xml:lang='x-bibl']/@text"/>
            </marc:subfield>
          </xsl:when>
          <xsl:when
              test="mods:languageTerm[@objectPart='summary or abstract' or @objectPart='summary' or @objectPart='abstract']">
            <marc:subfield code='b'>
              <xsl:value-of select="$rfc4646//category[@ID=$lang]/label[@xml:lang='x-bibl']/@text"/>
            </marc:subfield>
          </xsl:when>
          <xsl:when test="mods:languageTerm[@objectPart='sung or spoken text']">
            <marc:subfield code='d'>
              <xsl:value-of select="$rfc4646//category[@ID=$lang]/label[@xml:lang='x-bibl']/@text"/>
            </marc:subfield>
          </xsl:when>
          <xsl:when test="mods:languageTerm[@objectPart='librettos' or @objectPart='libretto']">
            <marc:subfield code='e'>
              <xsl:value-of select="$rfc4646//category[@ID=$lang]/label[@xml:lang='x-bibl']/@text"/>
            </marc:subfield>
          </xsl:when>
          <xsl:when test="mods:languageTerm[@objectPart='table of contents']">
            <marc:subfield code='f'>
              <xsl:value-of select="$rfc4646//category[@ID=$lang]/label[@xml:lang='x-bibl']/@text"/>
            </marc:subfield>
          </xsl:when>
          <xsl:when
              test="mods:languageTerm[@objectPart='accompanying material other than librettos' or @objectPart='accompanying material']">
            <marc:subfield code='g'>
              <xsl:value-of select="$rfc4646//category[@ID=$lang]/label[@xml:lang='x-bibl']/@text"/>
            </marc:subfield>
          </xsl:when>
          <xsl:when
              test="mods:languageTerm[@objectPart='original and/or intermediate translations of text' or @objectPart='translation']">
            <marc:subfield code='h'>
              <xsl:value-of select="$rfc4646//category[@ID=$lang]/label[@xml:lang='x-bibl']/@text"/>
            </marc:subfield>
          </xsl:when>
          <xsl:when test="mods:languageTerm[@objectPart='subtitles or captions' or @objectPart='subtitle or caption']">
            <marc:subfield code='j'>
              <xsl:value-of select="$rfc4646//category[@ID=$lang]/label[@xml:lang='x-bibl']/@text"/>
            </marc:subfield>
          </xsl:when>
          <xsl:otherwise>
            <marc:subfield code='a'>
              <xsl:value-of select="$rfc4646//category[@ID=$lang]/label[@xml:lang='x-bibl']/@text"/>
            </marc:subfield>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:language/mods:languageTerm[@authority='iso639-2b']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">041</xsl:with-param>
      <xsl:with-param name="ind1">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:language/mods:languageTerm[@authority='rfc3066']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">041</xsl:with-param>
      <xsl:with-param name="ind1">0</xsl:with-param>
      <xsl:with-param name="ind2">7</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="."/>
        </marc:subfield>
        <marc:subfield code='2'>rfc3066</marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:language/mods:languageTerm[@authority='rfc3066']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">546</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='b'>
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Physical Description -->
  <xsl:template match="mods:physicalDescription">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mods:extent">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">300</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <!-- add '1 Online-Ressource' -->
          <xsl:if test="not(contains(.,'Online-Ressource'))">
            <xsl:text>1 Online-Ressource </xsl:text>
          </xsl:if>
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:form[@type='material']|mods:form[@type='technique']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:choose>
          <xsl:when test="@type='material'">340</xsl:when>
          <xsl:when test="@type='technique'">340</xsl:when>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:if test="not(@type='technique')">
          <marc:subfield code="a">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:if>
        <!-- add subfield b-->
        <xsl:if test="@code!=''">
          <marc:subfield code="b">
            <xsl:value-of select="@code"/>
          </marc:subfield>
        </xsl:if>
        <xsl:if test="@type='technique'">
          <marc:subfield code="d">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:if>
        <xsl:if test="@authority">
          <marc:subfield code="2">
            <xsl:value-of select="@authority"/>
          </marc:subfield>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Abstract -->
  <xsl:template match="mods:abstract">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">520</xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:choose>
          <xsl:when test="@displayLabel='Subject'">0</xsl:when>
          <xsl:when test="@displayLabel='Review'">1</xsl:when>
          <xsl:when test="@displayLabel='Scope and content'">2</xsl:when>
          <xsl:when test="@displayLabel='Abstract'">2</xsl:when>
          <xsl:when test="@displayLabel='Content advice'">4</xsl:when>
          <xsl:otherwise>
            <xsl:text> </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <!-- delete CR and NL -->
          <xsl:value-of select="translate(., '&#10;&#13;', ' ')"/>
        </marc:subfield>
        <xsl:for-each select="@xlink:href">
          <marc:subfield code="u">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Table of Contents -->
  <xsl:template match="mods:tableOfContents">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">505</xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:choose>
          <xsl:when test="@displayLabel='Contents'">0</xsl:when>
          <xsl:when test="@displayLabel='Incomplete contents'">1</xsl:when>
          <xsl:when test="@displayLabel='Partial contents'">2</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
        <xsl:for-each select="@xlink:href">
          <marc:subfield code="u">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Target Audience -->
  <xsl:template match="mods:targetAudience[not(@authority)] | mods:targetAudience[@authority!='marctarget']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">521</xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:choose>
          <xsl:when test="@displayLabel='Reading grade level'">0</xsl:when>
          <xsl:when test="@displayLabel='Interest age level'">1</xsl:when>
          <xsl:when test="@displayLabel='Interest grade level'">2</xsl:when>
          <xsl:when test="@displayLabel='Special audience characteristics'">3</xsl:when>
          <xsl:when test="@displayLabel='Motivation or interest level'">3</xsl:when>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Note -->
  <xsl:template match="mods:note[not(@type='statement of responsibility')]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:choose>
          <xsl:when test="@type='performers'">511</xsl:when>
          <xsl:when test="@type='venue'">518</xsl:when>
          <xsl:otherwise>500</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:for-each select="@xlink:href">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">856</xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code='u'>
            <xsl:value-of select="."/>
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
          <xsl:when test="@type='embargo'">506</xsl:when>
          <xsl:when test="@type='useAndReproduction'">540</xsl:when>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code='a'>
          <xsl:value-of select="concat('embargo until ',.)"/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="controlRecordInfo">
    <marc:controlfield tag="001">
      <xsl:choose>
        <xsl:when test="mods:recordInfo/mods:recordIdentifier">
          <xsl:value-of select="mods:recordInfo/mods:recordIdentifier"/>
        </xsl:when>
        <!-- show dbt_mods_ID if no ppn is present-->
        <xsl:otherwise>
          <xsl:value-of select="@ID"/>
        </xsl:otherwise>
      </xsl:choose>
    </marc:controlfield>
    <!-- show GBV (DE-601) as source for ppn-numbers, db-thueringen.de as source for dbt_mods_... -->
    <marc:controlfield tag="003">
      <xsl:choose>
        <xsl:when test=".[@source]">
          <xsl:value-of select="./@source"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>db-thueringen.de</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </marc:controlfield>
    <xsl:for-each select="mods:recordInfo/mods:recordChangeDate[@encoding='iso8601']">
      <marc:controlfield tag="005">
        <xsl:value-of select="."/>
      </marc:controlfield>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="source">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">
        <xsl:text>040</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <!-- set cataloging language to german -->
        <marc:subfield code="b">
          <xsl:text>ger</xsl:text>
        </marc:subfield>
        <!-- set cataloging source to 'DE-601' (GBV) -->
        <marc:subfield code="c">
          <xsl:text>DE-601</xsl:text>
        </marc:subfield>
        <!-- set cataloging rules to RDA -->
        <marc:subfield code="e">
          <xsl:text>rda</xsl:text>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:subject">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mods:subject[local-name(*[1])='titleInfo']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">630</xsl:with-param>
      <xsl:with-param name="ind1">
        <xsl:value-of select="string-length(mods:titleInfo/mods:nonSort)+1"/>
      </xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd"/>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:for-each select="mods:titleInfo">
          <xsl:call-template name="titleInfo"/>
        </xsl:for-each>
        <xsl:apply-templates select="*[position()>1]"/>
      </xsl:with-param>
    </xsl:call-template>

  </xsl:template>

  <xsl:template match="mods:subject[local-name(*[1])='name']">
    <xsl:for-each select="*[1]">
      <xsl:choose>
        <xsl:when test="@type='personal'">
          <xsl:call-template name="datafield">
            <xsl:with-param name="tag">600</xsl:with-param>
            <xsl:with-param name="ind1">1</xsl:with-param>
            <xsl:with-param name="ind2">
              <xsl:call-template name="authorityInd"/>
            </xsl:with-param>
            <xsl:with-param name="subfields">
              <marc:subfield code="a">
                <xsl:value-of select="mods:namePart"/>
              </marc:subfield>
              <xsl:for-each select="mods:namePart[@type='termsOfAddress']">
                <marc:subfield code="c">
                  <xsl:value-of select="."/>
                </marc:subfield>
              </xsl:for-each>
              <xsl:for-each select="mods:namePart[@type='date']">
                <marc:subfield code="d">
                  <xsl:value-of select="."/>
                </marc:subfield>
              </xsl:for-each>
              <xsl:for-each select="mods:role/mods:roleTerm[@type='text']">
                <marc:subfield code="e">
                  <xsl:value-of select="."/>
                </marc:subfield>
              </xsl:for-each>
              <xsl:for-each select="mods:affiliation">
                <marc:subfield code="u">
                  <xsl:value-of select="."/>
                </marc:subfield>
              </xsl:for-each>
              <xsl:apply-templates select="*[position()>1]"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="@type='corporate'">
          <xsl:call-template name="datafield">
            <xsl:with-param name="tag">610</xsl:with-param>
            <xsl:with-param name="ind1">2</xsl:with-param>
            <xsl:with-param name="ind2">
              <xsl:call-template name="authorityInd"/>
            </xsl:with-param>
            <xsl:with-param name="subfields">
              <marc:subfield code="a">
                <xsl:value-of select="mods:namePart[1]"/>
              </marc:subfield>
              <marc:subfield code="b">
                <xsl:value-of select="mods:namePart[position()>1]"/>
              </marc:subfield>
              <xsl:for-each select="mods:role/mods:roleTerm[@type='text']">
                <marc:subfield code="e">
                  <xsl:value-of select="."/>
                </marc:subfield>
              </xsl:for-each>
              <xsl:apply-templates select="ancestor-or-self::mods:subject/*[position()>1]"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="@type='conference'">
          <xsl:call-template name="datafield">
            <xsl:with-param name="tag">611</xsl:with-param>
            <xsl:with-param name="ind1">2</xsl:with-param>
            <xsl:with-param name="ind2">
              <xsl:call-template name="authorityInd"/>
            </xsl:with-param>
            <xsl:with-param name="subfields">
              <marc:subfield code="a">
                <xsl:value-of select="mods:namePart"/>
              </marc:subfield>
              <xsl:for-each select="mods:role/mods:roleTerm[@type='code']">
                <marc:subfield code="4">
                  <xsl:value-of select="."/>
                </marc:subfield>
              </xsl:for-each>
              <xsl:apply-templates select="*[position()>1]"/>
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
      <xsl:with-param name="tag">651</xsl:with-param>
      <!-- set first indicator equal to ' ', second indicator depending on source -->
      <xsl:with-param name="ind1"/>
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd"/>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <!-- put all topical terms in subfield a, one field 651a per term -->
        <xsl:for-each select=".">
          <marc:subfield code="a">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
        <!-- add subfield 2 (source) -->
        <xsl:for-each select=".">
          <xsl:choose>
            <xsl:when test="./@authority">
              <marc:subfield code="2">
                <xsl:value-of select="@authority"/>
              </marc:subfield>
            </xsl:when>
            <xsl:when test="../@authority">
              <marc:subfield code="2">
                <xsl:value-of select="../@authority"/>
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
      <xsl:with-param name="tag">651</xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd"/>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="*[1]"/>
        </marc:subfield>
        <xsl:apply-templates select="*[position()&gt;1]"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- mods:temporal not lcsh -->
  <xsl:template
      match="mods:subject[(@authority!='lcsh' and @authority!='lcshac' and @authority!='mesh' and @authority!='csh' and @authority!='nal' and @authority!='rvm') or not(@authority)]/mods:temporal[(@authority!='lcsh' and @authority!='lcshac' and @authority!='mesh' and @authority!='csh' and @authority!='nal' and @authority!='rvm') or not(@authority)]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">650</xsl:with-param>
      <!-- set first indicator equal to ' ', second indicator depending on source -->
      <xsl:with-param name="ind1"/>
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd"/>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <!-- put all topical terms in subfield a, one field 650a per term -->
        <xsl:for-each select=".">
          <marc:subfield code="a">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
        <!-- add subfield 2 (source) -->
        <xsl:for-each select=".">
          <xsl:choose>
            <xsl:when test="./@authority">
              <marc:subfield code="2">
                <xsl:value-of select="@authority"/>
              </marc:subfield>
            </xsl:when>
            <xsl:when test="../@authority">
              <marc:subfield code="2">
                <xsl:value-of select="../@authority"/>
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
      <xsl:with-param name="tag">650</xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd"/>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="*[1]"/>
        </marc:subfield>
        <xsl:apply-templates select="*[position()>1]"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:subject/mods:geographicCode[@authority]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">043</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:for-each select="self::mods:geographicCode[@authority='marcgac']">
          <marc:subfield code='a'>
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="self::mods:geographicCode[@authority='iso3166']">
          <marc:subfield code='c'>
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:subject/mods:heirarchialGeographic">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">752</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:for-each select="mods:country">
          <marc:subfield code="a">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="mods:state">
          <marc:subfield code="b">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="mods:county">
          <marc:subfield code="c">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="mods:city">
          <marc:subfield code="d">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:subject/mods:cartographics">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">255</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:for-each select="mods:coordinates">
          <marc:subfield code="c">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="mods:scale">
          <marc:subfield code="a">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="mods:projection">
          <marc:subfield code="b">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:subject/mods:occupation">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">656</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- mods:topic not lcsh -->
  <xsl:template
      match="mods:subject[(@authority!='lcsh' and @authority!='lcshac' and @authority!='mesh' and @authority!='csh' and @authority!='nal' and @authority!='rvm') or not(@authority)]/mods:topic[(@authority!='lcsh' and @authority!='lcshac' and @authority!='mesh' and @authority!='csh' and @authority!='nal' and @authority!='rvm') or not(@authority)]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">650</xsl:with-param>
      <!-- set first indicator equal to ' ', second indicator depending on source -->
      <xsl:with-param name="ind1"/>
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd"/>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <!-- put all topical terms in subfield a, one field 650a per term -->
        <xsl:for-each select=".">
          <marc:subfield code="a">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
        <!-- add subfield 2 (source) -->
        <xsl:for-each select=".">
          <xsl:choose>
            <xsl:when test="./@authority">
              <marc:subfield code="2">
                <xsl:value-of select="./@authority"/>
              </marc:subfield>
            </xsl:when>
            <xsl:when test="../@authority">
              <marc:subfield code="2">
                <xsl:value-of select="../@authority"/>
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
      <xsl:with-param name="tag">650</xsl:with-param>
      <xsl:with-param name="ind1">1</xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:call-template name="authorityInd"/>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="*[1]"/>
        </marc:subfield>
        <xsl:apply-templates select="*[position()>1]"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template
      match="mods:subject[@authority='lcsh' or @authority='lcshac' or @authority='mesh' or @authority='csh' or @authority='nal' or @authority='rvm']/mods:topic">
    <marc:subfield code="x">
      <xsl:value-of select="."/>
    </marc:subfield>
  </xsl:template>

  <xsl:template
      match="mods:subject[@authority='lcsh' or @authority='lcshac' or @authority='mesh' or @authority='csh' or @authority='nal' or @authority='rvm']/mods:temporal">
    <marc:subfield code="y">
      <xsl:value-of select="."/>
    </marc:subfield>
  </xsl:template>

  <xsl:template
      match="mods:subject[@authority='lcsh' or @authority='lcshac' or @authority='mesh' or @authority='csh' or @authority='nal' or @authority='rvm']/mods:geographic">
    <marc:subfield code="z">
      <xsl:value-of select="."/>
    </marc:subfield>
  </xsl:template>

  <xsl:template name="titleInfo">
    <xsl:for-each select="mods:title">
      <marc:subfield code="a">
        <!-- add additional space -->
        <xsl:if test="../mods:nonSort">
          <xsl:value-of select="concat(../mods:nonSort,' ')"/>
        </xsl:if>
        <xsl:value-of select="."/>
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:subTitle">
      <marc:subfield code="b">
        <xsl:value-of select="."/>
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:partNumber">
      <marc:subfield code="n">
        <xsl:value-of select="."/>
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:partName">
      <marc:subfield code="p">
        <xsl:value-of select="."/>
      </marc:subfield>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="stmtOfResponsibility">
    <xsl:choose>
      <xsl:when test="../mods:note[@type='statement of responsibility']">
        <marc:subfield code='c'>
          <xsl:value-of select="../mods:note[@type='statement of responsibility']"/>
        </marc:subfield>
      </xsl:when>
      <xsl:otherwise>
        <marc:subfield code="c">
          <xsl:for-each
              select="/mods:mods/mods:name/mods:displayForm[../mods:role/mods:roleTerm[@type='code']!='rev'][../mods:role/mods:roleTerm[@type='code']!='pbl'][../mods:role/mods:roleTerm[@type='code']!='dst']">
            <xsl:value-of select="."/>
            <xsl:if test="position()!=last()">;</xsl:if>
          </xsl:for-each>
        </marc:subfield>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Classification -->
  <xsl:template match="mods:classification[@authority='ddc']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">082</xsl:with-param>
      <xsl:with-param name="ind1">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
        <xsl:for-each select="@edition">
          <marc:subfield code="2">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='udc']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">080</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='nlm']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">060</xsl:with-param>
      <xsl:with-param name="ind2">4</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='sudocs']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">086</xsl:with-param>
      <xsl:with-param name="ind1">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='candocs']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">086</xsl:with-param>
      <xsl:with-param name="ind1">1</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='content']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">084</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- add other classifications  (e.g. sdnb, rvk, bkl) -->
  <xsl:template match="mods:classification[@authority]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">084</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
        <marc:subfield code="2">
          <xsl:value-of select="./@authority"/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="lcClassification">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">050</xsl:with-param>
      <xsl:with-param name="ind2">
        <xsl:choose>
          <xsl:when
              test="../mods:recordInfo/mods:recordContentSource='DLC' or ../mods:recordInfo/mods:recordContentSource='Library of Congress'">
            0
          </xsl:when>
          <!-- set indicator equal to '4' (assigned by agency other than LC) -->
          <xsl:otherwise>4</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:for-each select="mods:classification[@authority='lcc']">
          <marc:subfield code="a">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Identifiers -->
  <xsl:template match="mods:identifier[@type='doi'] | mods:identifier[@type='hdl']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">024</xsl:with-param>
      <!-- set first indicator equal to '7' (source specified in subfield 2) -->
      <xsl:with-param name="ind1">7</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
        <marc:subfield code="2">
          <xsl:value-of select="@type"/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='isbn']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">020</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">z</xsl:when>
              <xsl:otherwise>a</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='isrc']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">024</xsl:with-param>
      <xsl:with-param name="ind1">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">z</xsl:when>
              <xsl:otherwise>a</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='ismn']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">024</xsl:with-param>
      <xsl:with-param name="ind1">2</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">z</xsl:when>
              <xsl:otherwise>a</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='issn'] | mods:identifier[@type='issn-l'] ">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">022</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">z</xsl:when>
              <xsl:otherwise>a</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='issue number']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">028</xsl:with-param>
      <xsl:with-param name="ind1">0</xsl:with-param>
      <xsl:with-param name="ind2">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='lccn']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">010</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">z</xsl:when>
              <xsl:otherwise>a</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='matrix number']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">028</xsl:with-param>
      <xsl:with-param name="ind1">1</xsl:with-param>
      <xsl:with-param name="ind2">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='music publisher']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">028</xsl:with-param>
      <xsl:with-param name="ind1">3</xsl:with-param>
      <xsl:with-param name="ind2">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='music plate']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">028</xsl:with-param>
      <xsl:with-param name="ind1">2</xsl:with-param>
      <xsl:with-param name="ind2">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='sici']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">024</xsl:with-param>
      <xsl:with-param name="ind1">4</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">z</xsl:when>
              <xsl:otherwise>a</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='stocknumber']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">037</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='uri']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">856</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="u">
          <xsl:value-of select="."/>
        </marc:subfield>
        <xsl:call-template name="mediaType"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="mods:location[mods:url]">
    <xsl:for-each select="mods:url">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">856</xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="u">
            <xsl:value-of select="."/>
          </marc:subfield>
          <xsl:for-each select="@displayLabel">
            <marc:subfield code="3">
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:for-each>
          <xsl:for-each select="@dateLastAccessed">
            <marc:subfield code="z">
              <xsl:value-of select="concat('Last accessed: ',.)"/>
            </marc:subfield>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="mods:identifier[@type='upc']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">024</xsl:with-param>
      <xsl:with-param name="ind1">1</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield>
          <xsl:attribute name="code">
            <xsl:choose>
              <xsl:when test="@invalid='yes'">z</xsl:when>
              <xsl:otherwise>a</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='videorecording']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">028</xsl:with-param>
      <xsl:with-param name="ind1">4</xsl:with-param>
      <xsl:with-param name="ind2">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xsl:template name="authorityInd">
    <xsl:choose>
      <xsl:when test="@authority='lcsh' or ../@authority='lcsh'">0</xsl:when>
      <xsl:when test="@authority='lcshac' or ../@authority='lcshac'">1</xsl:when>
      <xsl:when test="@authority='mesh' or ../@authority='mesh'">2</xsl:when>
      <xsl:when test="@authority='csh' or ../@authority='csh'">3</xsl:when>
      <xsl:when test="@authority='nal' or ../@authority='nal'">5</xsl:when>
      <xsl:when test="@authority='rvm' or ../@authority='rvm'">6</xsl:when>
      <xsl:when test="@authority or ../@authority">7</xsl:when>
      <xsl:otherwise>4</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:relatedItem/mods:identifier[@type='uri']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">856</xsl:with-param>
      <xsl:with-param name="ind2">2</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="u">
          <xsl:value-of select="."/>
        </marc:subfield>
        <xsl:call-template name="mediaType"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:location[mods:physicalLocation]">
    <xsl:for-each select="mods:physicalLocation">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">852</xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="a">
            <xsl:value-of select="."/>
          </marc:subfield>
          <xsl:for-each select="@displayLabel">
            <marc:subfield code="3">
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:location[mods:physicalLocation[@xlink]]">
    <xsl:for-each select="mods:physicalLocation">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">852</xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="u">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="mods:location[mods:uri]">
    <xsl:for-each select="mods:uri">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">852</xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield>
            <xsl:choose>
              <xsl:when test="@displayLabel='content'">3</xsl:when>
              <xsl:when test="@dateLastAccessed='content'">z</xsl:when>
              <xsl:when test="@note='contents of subfield'">z</xsl:when>
              <xsl:when test="@access='preview'">3</xsl:when>
              <xsl:when test="@access='raw object'">3</xsl:when>
              <xsl:when test="@access='object in context'">3</xsl:when>
              <xsl:when test="@access='primary display'">z</xsl:when>
            </xsl:choose>
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:extension">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">887</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="mediaType">
    <xsl:if test="../mods:physicalDescription/mods:internetMediaType">
      <marc:subfield code="q">
        <xsl:value-of select="../mods:physicalDescription/mods:internetMediaType"/>
      </marc:subfield>
    </xsl:if>
  </xsl:template>

  <xsl:template name="form">
    <xsl:if test="../mods:physicalDescription/mods:form[@authority='gmd']">
      <marc:subfield code="h">
        <xsl:value-of select="../mods:physicalDescription/mods:form[@authority='gmd']"/>
      </marc:subfield>
    </xsl:if>
  </xsl:template>

  <!-- use definded query for isReferencedBy (see above) -->
  <xsl:template match="mods:mods" mode="isReferencedBy">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">510</xsl:with-param>
      <xsl:with-param name="subfields">
        <marc:subfield code="a">
          <xsl:value-of
              select="concat(mods:titleInfo/mods:title[not(ancestor-or-self::mods:titleInfo/@type)],' (',mods:identifier[@type='local']|@xlink:href|@ID, ')')"/>
        </marc:subfield>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='series']">
    <!-- 490 - use field 490 instead of 440, set first indicator equal to '0' (series not traced)-->
    <xsl:for-each select="mods:titleInfo">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">490</xsl:with-param>
        <xsl:with-param name="ind1">0</xsl:with-param>
        <xsl:with-param name="subfields">
          <xsl:call-template name="titleInfo"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <!-- 810 -->
    <xsl:for-each select="mods:name">
      <xsl:call-template name="datafield">
        <xsl:with-param name="tag">
          <xsl:choose>
            <xsl:when test="@type='personal'">800</xsl:when>
            <xsl:when test="@type='corporate'">810</xsl:when>
            <xsl:when test="@type='conference'">811</xsl:when>
            <xsl:otherwise>800</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <!-- set first indicator depending on type of series added entry -->
        <xsl:with-param name="ind1">
          <xsl:choose>
            <xsl:when test="@type='personal'">1</xsl:when>
            <xsl:when test="@type='corporate'">2</xsl:when>
            <xsl:when test="@type='conference'">2</xsl:when>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="subfields">
          <marc:subfield code="a">
            <xsl:choose>
              <!-- if university. institute is given -->
              <xsl:when test="contains(mods:displayForm,'.')">
                <xsl:value-of select="substring-before(mods:displayForm,'.')"/>
              </xsl:when>
              <!-- if institution nameParts are given -->
              <xsl:when test="mods:namePart">
                <xsl:value-of select="mods:namePart[1]"/>
              </xsl:when>
              <!-- if only whole institution name is given -->
              <xsl:when test="mods:displayForm">
                <xsl:value-of select="mods:displayForm"/>
              </xsl:when>
              <!-- if no institution name is given, but @valueURI is present -->
              <!-- TODO resolve @valueURI locally (names of institution and universites) -->
              <xsl:when test="@valueURI">
                <xsl:variable name="categId" select="substring-after(@valueURI, '#')"/>
                <xsl:variable name="institute" select="$institutes//category[@ID=$categId]"/>
                <xsl:apply-templates select="$institute" mode="name110-710-810-1"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="mods:displayForm"/>
              </xsl:otherwise>
            </xsl:choose>
          </marc:subfield>
          <marc:subfield code="b">
            <xsl:choose>
              <!-- if university.institute is given -->
              <xsl:when test="contains(mods:displayForm,'.')">
                <xsl:value-of select="substring-after(mods:displayForm,'. ')"/>
              </xsl:when>
              <!-- if institution nameParts are given -->
              <xsl:when test="mods:namePart">
                <xsl:value-of select="mods:namePart[position()>1]"/>
              </xsl:when>
              <!-- if only whole institution name is given (whole name in subfield a, subfield b is empty) -->
              <xsl:when test="mods:displayForm"/>
              <!-- if no institution name is given, but @valueURI is present -->
              <!-- TODO resolve @valueURI locally (names of institution and universites) -->
              <xsl:when test="@valueURI">
                <xsl:variable name="categId" select="substring-after(@valueURI, '#')"/>
                <xsl:variable name="institute" select="$institutes//category[@ID=$categId]"/>
                <xsl:apply-templates select="$institute" mode="name110-710-810-2"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="mods:namePart[position()&gt;1]"/>
              </xsl:otherwise>
            </xsl:choose>
          </marc:subfield>
          <xsl:if test="@type='personal'">
            <marc:subfield code="c">
              <xsl:value-of select="mods:namePart[@type='termsOfAddress']"/>
            </marc:subfield>
            <marc:subfield code="d">
              <xsl:value-of select="mods:namePart[@type='date']"/>
            </marc:subfield>
          </xsl:if>
          <xsl:if test="@type!='conference'">
            <marc:subfield code="e">
              <!-- TODO add labels to modsenhancer/relacode (update) ('issuing body' for 'isb' and 'host institution' for 'his') -->
              <xsl:choose>
                <xsl:when test="../mods:roleTerm[@type='code']='isb'">issuing body</xsl:when>
                <xsl:when test="../mods:roleTerm[@type='code']='his'">host institution</xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="mods:role/mods:roleTerm[@type='text']"/>
                </xsl:otherwise>
              </xsl:choose>
            </marc:subfield>
          </xsl:if>
          <marc:subfield code="4">
            <xsl:value-of select="mods:role/mods:roleTerm[@type='code']"/>
          </marc:subfield>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mods:relatedItem[not(@type)]">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">787</xsl:with-param>
      <xsl:with-param name="ind1">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='preceding']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">780</xsl:with-param>
      <xsl:with-param name="ind1">0</xsl:with-param>
      <xsl:with-param name="ind2">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- use definded query for succeeding (see above) -->
  <xsl:template match="mods:mods" mode="succeeding">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">785</xsl:with-param>
      <xsl:with-param name="ind1">0</xsl:with-param>
      <xsl:with-param name="ind2">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='otherVersion']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">775</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='otherFormat']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">776</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='original']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">534</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='host']">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">773</xsl:with-param>
      <xsl:with-param name="ind1">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:for-each select="@displaylabel">
          <marc:subfield code="3">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
        <xsl:for-each select="mods:part/mods:text">
          <marc:subfield code="g">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
        <xsl:call-template name="relatedItem76X-78X"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- use definded query for constituent (see above) -->
  <xsl:template match="mods:mods" mode="constituent">
    <xsl:call-template name="datafield">
      <xsl:with-param name="tag">774</xsl:with-param>
      <xsl:with-param name="ind1">0</xsl:with-param>
      <xsl:with-param name="subfields">
        <xsl:call-template name="relatedItem76X-78X"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="relatedItem76X-78X">
    <xsl:call-template name="relatedItemNames"/>
    <xsl:for-each select="mods:titleInfo">
      <xsl:for-each select="mods:title">
        <xsl:choose>
          <xsl:when test="not(ancestor-or-self::mods:titleInfo/@type)">
            <marc:subfield code="t">
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:when>
          <xsl:when test="ancestor-or-self::mods:titleInfo/@type='uniform'">
            <marc:subfield code="s">
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:when>
          <xsl:when test="ancestor-or-self::mods:titleInfo/@type='abbreviated'">
            <marc:subfield code="p">
              <xsl:value-of select="."/>
            </marc:subfield>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
      <xsl:for-each select="mods:partNumber">
        <marc:subfield code="g">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:for-each>
      <xsl:for-each select="mods:partName">
        <marc:subfield code="g">
          <xsl:value-of select="."/>
        </marc:subfield>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:if test="mods:part/mods:detail">
      <xsl:variable name="parts">
        <xsl:for-each select="mods:part/mods:detail">
          <xsl:value-of select="concat(mods:number,':')"/>
        </xsl:for-each>
      </xsl:variable>
      <marc:subfield code="q">
        <xsl:value-of
            select="concat(substring($parts,1,string-length($parts)-1),'&lt;',mods:part/mods:extent/mods:start)"/>
      </marc:subfield>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@type='original'">
        <xsl:for-each select="mods:physicalDescription/mods:extent">
          <marc:subfield code="e">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="@type!='original'">
        <xsl:for-each select="mods:physicalDescription/mods:extent">
          <marc:subfield code="h">
            <xsl:value-of select="."/>
          </marc:subfield>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
    <xsl:for-each select="@displayLabel">
      <marc:subfield code="i">
        <xsl:value-of select="."/>
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:identifier[not(@type)]">
      <marc:subfield code="o">
        <xsl:value-of select="."/>
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:identifier[@type='issn']">
      <marc:subfield code="x">
        <xsl:value-of select="."/>
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:identifier[@type='isbn']">
      <marc:subfield code="z">
        <xsl:value-of select="."/>
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:identifier[@type='local']|@xlink:href|@ID">
      <marc:subfield code="w">
        <xsl:value-of select="."/>
      </marc:subfield>
    </xsl:for-each>
    <xsl:for-each select="mods:note">
      <marc:subfield code="n">
        <xsl:value-of select="."/>
      </marc:subfield>
    </xsl:for-each>
  </xsl:template>

  <!-- subfield a contains only names, no additional role terms -->
  <xsl:template name="relatedItemNames">
    <xsl:if test="mods:name">
      <marc:subfield code="a">
        <xsl:variable name="nameString">
          <xsl:for-each select="mods:name">
            <xsl:value-of select="mods:namePart[1][not(@type='date')]"/>
            <xsl:if test="mods:namePart[position()&gt;1][@type='date']">
              <xsl:value-of select="concat(' ',mods:namePart[position()&gt;1][@type='date'])"/>
            </xsl:if>
            <xsl:if test="position()!=last()">
              <xsl:text>; </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring($nameString, 1,string-length($nameString)-2)"/>
      </marc:subfield>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

    <!-- Übersicht der Änderungen:
    - 001: dbt_mods-ID eingesetzt falls keine ppn vorhanden
    - 003: GBV (DE-601) als Quelle für ppn angegeben, db-thueringen.de als Quelle für dbt_mods_... angegeben
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
    - 300: Vermerk '1 Online-Ressource' hinzugefügt
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
    - 773: Reihenfolge der subfields angepasst (a, t, g, q, w, n)
    - 810: Ersten Indikator gleich 1 bzw. 2 gesetzt (Unterscheidung ob personal, corporate, meeting)
    - 510/774/784: query for relatedItem host,series -> constituent, preceding -> succeeding, references -> isReferencedBy
    -->

    <!-- TODO
    - resolve language code classification locally (field 041) -> Code in templates entsprechend anpassen
    - resolve @valueURI locally (names of institution and universites) (fields 110/710/810) -> Code in templates entsprechend anpassen
    - add labels to modsenhancer/relacode (update) ('issuing body' for 'isb' and 'host institution' for 'his') (fields 110/710/810) -> danach entsprechenden Code in templates löschen (vorläufig als Ersatz eingefügt)
    -->
