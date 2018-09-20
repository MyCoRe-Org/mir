<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:java="http://xml.apache.org/xalan/java"
  xmlns:oai="http://www.openarchives.org/OAI/2.0/"
  xmlns:mab="http://www.ddb.de/professionell/mabxml/mabxml-1.xsd"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="xsl xalan java oai mab">

  <xsl:template match="/oai:OAI-PMH">
    <xsl:apply-templates select="oai:ListRecords/oai:record[1]/oai:metadata/mab:record" />
  </xsl:template>

  <xsl:template match="mab:record">
    <mods:mods>
      <mods:titleInfo>
        <xsl:apply-templates select="mab:datafield[@tag='331']" />
        <xsl:apply-templates select="mab:datafield[@tag='335']" />
      </mods:titleInfo>
      <xsl:apply-templates select="mab:datafield[@tag='100']" />
      <xsl:apply-templates select="mab:datafield[@tag='104']" />
      <xsl:apply-templates select="mab:datafield[@tag='108']" />
      <mods:originInfo>
        <xsl:apply-templates select="mab:datafield[@tag='410']/mab:subfield[@code='a']|mab:datafield[@tag='419']/mab:subfield[@code='a']" />
        <xsl:apply-templates select="mab:datafield[@tag='412']/mab:subfield[@code='a']|mab:datafield[@tag='419']/mab:subfield[@code='b']" />
        <xsl:apply-templates select="mab:datafield[@tag='425']" />
      </mods:originInfo>
      <xsl:apply-templates select="mab:datafield[@tag='433']" />
      <xsl:apply-templates select="mab:datafield[@tag='451']" />
      <xsl:apply-templates select="mab:datafield[@tag='540'][1]/mab:subfield[@code='a']" />
      <xsl:apply-templates select="mab:datafield[@tag='552'][1]/mab:subfield[@code='a']" />
      <xsl:apply-templates select="mab:datafield[@tag='519']|mab:datafield[@tag='520']" />
      <xsl:apply-templates select="mab:datafield[@tag='037']/mab:subfield[@code='a']" />
      <mods:location>
        <xsl:apply-templates select="mab:datafield[@tag='088'][ (mab:subfield[@code='a']='464') or (mab:subfield[@code='a']='465') ][1]/mab:subfield[@code='c']" />
        <xsl:apply-templates select="mab:datafield[@tag='655']/mab:subfield[@code='u']" /> 
      </mods:location>
    </mods:mods>
  </xsl:template>
  
  <xsl:template match="mab:datafield[@tag='331']">
    <mods:title>
      <xsl:value-of select="mab:subfield[@code='a']" />
    </mods:title>
  </xsl:template>
  
  <xsl:template match="mab:datafield[@tag='335']">
    <mods:subTitle>
      <xsl:value-of select="mab:subfield[@code='a']" />
    </mods:subTitle>
  </xsl:template>

  <xsl:template match="mab:datafield[@tag='100']|mab:datafield[@tag='104']|mab:datafield[@tag='108']">
    <mods:name type="personal">
      <xsl:apply-templates select="mab:subfield[@code='p']|mab:subfield[@code='a']" mode="name" />
      <xsl:call-template name="role" />
      <xsl:apply-templates select="mab:subfield[@code='9'][starts-with(text(),'(DE-588)')]" />
    </mods:name>
  </xsl:template>
  
  <xsl:template match="mab:subfield[@code='p']|mab:subfield[@code='a']" mode="name">
    <mods:namePart type="family">
      <xsl:value-of select="substring-before(.,', ')" />
    </mods:namePart>
    <mods:namePart type="given">
      <xsl:value-of select="substring-after(.,', ')" />
    </mods:namePart>
  </xsl:template>
  
  <xsl:template name="role">
    <mods:role>
      <mods:roleTerm authority="marcrelator" type="code">
        <xsl:choose>
          <xsl:when test="mab:subfield[@code='4']='edt'">edt</xsl:when>
          <xsl:when test="contains(mab:subfield[@code='b'],'Hrsg')">edt</xsl:when>
          <xsl:otherwise>aut</xsl:otherwise>
        </xsl:choose>
      </mods:roleTerm>
    </mods:role>
  </xsl:template>
  
  <xsl:template match="mab:subfield[@code='9'][starts-with(text(),'(DE-588)')]">
    <mods:nameIdentifier type="gnd">
      <xsl:value-of select="substring-after(text(),'(DE-588)')" />
    </mods:nameIdentifier>
  </xsl:template>
  
  <xsl:template match="mab:datafield[@tag='410']/mab:subfield[@code='a']|mab:datafield[@tag='419']/mab:subfield[@code='a']">
    <mods:place>
      <mods:placeTerm type="text">
        <xsl:value-of select="text()" />
      </mods:placeTerm>
    </mods:place>
  </xsl:template>
  
  <xsl:template match="mab:datafield[@tag='412']/mab:subfield[@code='a']|mab:datafield[@tag='419']/mab:subfield[@code='b']">
    <mods:publisher>
      <xsl:value-of select="text()" />
    </mods:publisher>
  </xsl:template>

  <xsl:template match="mab:datafield[@tag='425']">
    <mods:dateIssued encoding="w3cdtf">
      <xsl:value-of select="mab:subfield[@code='a']" />
    </mods:dateIssued>
  </xsl:template>
  
  <!-- RAK: Duisburg, Essen, Univ., Diss., 2015 -->
  <xsl:template match="mab:datafield[@tag='519']">
    <mods:note>
      <xsl:if test="mab:subfield[@code='p']">
        <xsl:value-of select="mab:subfield[@code='p']" />
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:value-of select="mab:subfield[@code='a']" />
    </mods:note>
  </xsl:template>

  <!-- RDA: Dissertation, Universität Duisburg-Essen, 2015 -->
  <xsl:template match="mab:datafield[@tag='520']">
    <mods:note>
      <xsl:for-each select="mab:subfield[contains('bcd',@code)]">
        <xsl:value-of select="text()" />
        <xsl:if test="position() != last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </mods:note>
  </xsl:template>
  
  <xsl:template match="mab:datafield[@tag='540'][1]/mab:subfield[@code='a']">
    <mods:identifier type="isbn">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="mab:datafield[@tag='552'][1]/mab:subfield[@code='a']">
    <mods:identifier type="doi">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="mab:datafield[@tag='433'][1]">
    <mods:physicalDescription>
      <mods:extent>
        <xsl:value-of select="mab:subfield[@code='a']" />
      </mods:extent>
    </mods:physicalDescription>
  </xsl:template>

  <xsl:template match="mab:datafield[@tag='451'][1]">
    <xsl:for-each select="mab:subfield[@code='a']">
      <xsl:choose>
        <xsl:when test="contains(.,';')"> <!-- RAK -->
          <xsl:call-template name="series.volume">
            <xsl:with-param name="series" select="substring-before(.,';')" />
            <xsl:with-param name="volume" select="normalize-space(substring-after(.,';'))" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="../mab:subfield[@code='v']"> <!-- RDA -->
          <xsl:variable name="volume" select="java:java.lang.String.new(../mab:subfield[@code='v']/text())" />
          <xsl:call-template name="series.volume">
            <xsl:with-param name="series" select="text()" />
            <xsl:with-param name="volume" select="normalize-space(java:replaceAll($volume,'Band ',''))" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="series.volume">
            <xsl:with-param name="series" select="text()" />
            <xsl:with-param name="volume" select="''" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="series.volume">
    <xsl:param name="series" />
    <xsl:param name="volume" />
    
    <mods:relatedItem type="series">
      <mods:titleInfo>
        <mods:title>
          <xsl:value-of select="normalize-space($series)" />
        </mods:title>
      </mods:titleInfo>
      <xsl:if test="string-length($volume) &gt; 0">
        <mods:part>
          <mods:detail type="volume">
            <mods:number>
              <xsl:value-of select="$volume" />
            </mods:number>
          </mods:detail>
        </mods:part>
      </xsl:if>
      <mods:genre type="intern">series</mods:genre>
    </mods:relatedItem>
  </xsl:template>
  
  <xsl:template match="mab:datafield[@tag='037']/mab:subfield[@code='a']">
    <mods:language>
      <mods:languageTerm authority="rfc4646" type="code">
        <xsl:value-of select="document(concat('language:',.))/language/@xmlCode" />
      </mods:languageTerm>
    </mods:language>
  </xsl:template>

  <xsl:template match="mab:datafield[@tag='088']/mab:subfield[@code='c']">
    <mods:shelfLocator>
      <xsl:value-of select="." />
    </mods:shelfLocator>
  </xsl:template>
  
  <xsl:template match="mab:datafield[@tag='655']/mab:subfield[@code='u']">
    <mods:url>
      <xsl:value-of select="." />
    </mods:url>
  </xsl:template>

  <xsl:template match="*" />

</xsl:stylesheet>
