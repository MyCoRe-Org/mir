<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xalan">

  <xsl:param name="MCR.DOI.Resolver.MasterURL" select="''" />
  <xsl:param name="MCR.URN.Resolver.MasterURL" select="''" />

  <xsl:output encoding="UTF-8" media-type="text/plain" method="text" standalone="yes" indent="no" />

  <xsl:strip-space elements="*" />

  <xsl:template match="/">
    <xsl:variable name="all">
      <lines>
        <line>
          <xsl:text>000K  utf8</xsl:text>
        </line>
        <xsl:for-each select="mods:mods">
          <xsl:if test="contains(mods:identifier[@type='uri']/text(),'ppn:')">
            <line>
              <xsl:text>0100  </xsl:text>
              <xsl:value-of select="substring-after(mods:identifier[@type='uri']/text(), 'ppn:')" />
            </line>
          </xsl:if>
          <xsl:if test="contains(mods:recordInfo/mods:recordIdentifier[@source], 'DE-601')">
            <line>
              <xsl:text>0100  </xsl:text>
              <xsl:value-of select="." />
            </line>
          </xsl:if>
          <xsl:apply-templates select="." mode="pica3" />
          <xsl:call-template name="subject.topic" />
          <xsl:if test="not(mods:originInfo[mods:publisher or mods:placeTerm[@type='text']])">
          </xsl:if>
        </xsl:for-each>
      </lines>
    </xsl:variable>
    <xsl:variable name="allPicaLines" select="xalan:nodeset($all)" />
    <xsl:apply-templates select="$allPicaLines/lines/line" mode="sorted">
      <xsl:sort select="text()" />
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template name="subject.topic">
    <xsl:for-each select="mods:subject/mods:topic">
      <line>
        <xsl:text>5550  </xsl:text>
          <xsl:value-of select="text()" />
      </line>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="line" mode="sorted">
    <!--clear blank lines in output-->
    <xsl:if test="string-length(text())&gt;4">
      <xsl:value-of select="text()" />
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:physicalDescription/mods:form[@authority='marccategory']" mode="pica3">
    <line>
      <xsl:text>0500  </xsl:text>
      <xsl:choose>
        <xsl:when test="contains(text(), 'electronic resource') and ../mods:form[@authority='marcsmd'
        and contains(text(), 'remote')]">
          <xsl:text>O</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="../../mods:originInfo/mods:issuance[contains(text(), 'monographic')]">
          <xsl:text>a</xsl:text>
        </xsl:when>
      </xsl:choose>
      <!--<xsl:choose>
        <xsl:when test="">

        </xsl:when>
      </xsl:choose>-->
      <xsl:text>u</xsl:text>
    </line>
  </xsl:template>

  <xsl:template match="mods:originInfo[@eventType='publication' or ( not(@eventType) and not(../mods:originInfo[@eventType='publication']) )]/mods:dateIssued[@encoding='w3cdtf']" mode="pica3">
    <line>
      <xsl:text>1100  </xsl:text>
      <xsl:value-of select="substring-before(.,'-')" />
      <xsl:value-of select="concat('$c',.)" />
    </line>
  </xsl:template>

  <xsl:template match="mods:physicalDescription/mods:form[@authority='gmd']" mode="pica3">
    <line>
      <xsl:text>1208  </xsl:text>
      <xsl:value-of select="." />
    </line>
  </xsl:template>

  <xsl:template match="mods:language/mods:languageTerm[@authority='iso639-2b']" mode="pica3">
    <line>
      <xsl:text>1500  </xsl:text>
      <xsl:value-of select="." />
    </line>
  </xsl:template>
  
  <xsl:template match="mods:language/mods:languageTerm[@authority='rfc5646' and ( not (../mods:languageTerm[@authority='iso639-2b']) )]" mode="pica3">
    <line>
      <xsl:text>1500  </xsl:text>
      <xsl:value-of select="document(concat('language:',.))/language/@biblCode" />
    </line>
  </xsl:template>

  <xsl:template match="mods:titleInfo[@xml:lang and not(@type='alternative')]" mode="pica3">
    <line>
      <xsl:text>4000  </xsl:text>
      <xsl:value-of select="mods:title" />
      <xsl:if test="mods:subTitle">
      <xsl:text>$d</xsl:text>
      <xsl:value-of select="mods:subTitle" />
      </xsl:if>
      <xsl:choose>
        <xsl:when test="../mods:originInfo/mods:publisher[count(@*)=0]">
          <xsl:text>$h</xsl:text>
          <xsl:value-of select="../mods:originInfo/mods:publisher"/>
        </xsl:when>
        <xsl:when test="../mods:name[@type='corporate']/mods:namePart">
          <xsl:text>$h</xsl:text>
          <xsl:value-of select="../mods:name[@type='corporate']/mods:namePart"/>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="../mods:name[@type='personal']/mods:displayForm">
        <xsl:value-of select="concat('  [', ../mods:name[@type='personal']/mods:displayForm[1], ']')" />
      </xsl:if>
    </line>
  </xsl:template>

  <xsl:template match="mods:physicalDescription/mods:extent" mode="pica3">
    <line>
      <xsl:choose>
        <xsl:when test="contains(text(), ') ')">
          <xsl:text>4060  </xsl:text>
          <xsl:value-of select="concat(substring-before(text(), ')'), ')')" />
          <xsl:text>&#10;</xsl:text>
          <xsl:text>4061 </xsl:text>
          <xsl:value-of select="substring-after(text(), ')')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>4060  </xsl:text>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </line>
  </xsl:template>

  <xsl:template match="mods:originInfo/mods:edition" mode="pica3">
    <line>
      <xsl:text>4020  </xsl:text>
      <xsl:value-of select="." />
    </line>
  </xsl:template>

  <xsl:template match="mods:titleInfo[@type='alternative']/mods:title" mode="pica3">
    <line>
      <xsl:text>4200  </xsl:text>
      <xsl:value-of select="text()" />
    </line>
  </xsl:template>

  <!-- xsl:template match="mods:note" mode="pica3">
    <line>
      <xsl:text>4201  </xsl:text>
      <xsl:value-of select="text()" />
    </line>
  </xsl:template -->

  <xsl:template match="mods:abstract[not(@altFormat)]" mode="pica3">
    <line>
      <xsl:text>4209  </xsl:text>
      <xsl:value-of select="normalize-space(translate(.,'&#xA;&#xD;',' '))" />
    </line>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='sdnb']" mode="pica3">
    <line>
      <xsl:text>5051  </xsl:text>
      <xsl:value-of select="text()"/>
    </line>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='ddc']" mode="pica3">
    <line>
      <xsl:text>5010  </xsl:text>
      <xsl:value-of select="text()" />
    </line>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='lcc']" mode="pica3">
    <line>
      <xsl:text>5030  </xsl:text>
      <xsl:value-of select="text()" />
    </line>
  </xsl:template>

  <xsl:template match="mods:classification[@authority='bcl']" mode="pica3">
    <line>
      <xsl:text>5301  </xsl:text>
      <xsl:value-of select="text()"/>
    </line>
  </xsl:template>

  <xsl:template match="mods:name[@type='personal'][mods:role/mods:roleTerm='aut'][position()=1]" mode="pica3">
    <line>
      <xsl:text>3000  </xsl:text>
      <xsl:value-of select="mods:displayForm" />
    </line>
  </xsl:template>

  <xsl:template match="mods:name[@type='personal'][mods:role/mods:roleTerm='aut'][position()!=1]" mode="pica3">
    <line>
      <xsl:text>3010  </xsl:text>
      <xsl:value-of select="mods:displayForm" />
    </line>
  </xsl:template>

  <xsl:template match="mods:name[@type='corporate']" mode="pica3">
    <line>
      <xsl:choose>
        <xsl:when test="mods:namePart[@type='family']">
          <xsl:text>3110  </xsl:text> <!--If you place the elemnet directly under die <line> it will create an empty 3110 tag -->
          <xsl:value-of select="concat(mods:namePart[@type='family'], ', ', mods:namePart[@type='given'])" />
        </xsl:when>
        <xsl:when test="mods:namePart[not(@type='family')]">
          <xsl:text>3110  </xsl:text>
          <xsl:for-each select="mods:namePart">
            <xsl:value-of select="text()"/>
            <xsl:if test="position() != last()">
                <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="../mods:name/mods:nameIdentifier[@type='gnd'] and mods:namePart">
          <xsl:text> ; </xsl:text>
          <xsl:value-of select="concat('ID: ', 'gnd/', ../mods:name/mods:nameIdentifier[@type='gnd']/text())"/>
        </xsl:when>
      </xsl:choose>
    </line>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='doi']" mode="pica3">
    <line>
      <xsl:text>2051  </xsl:text>
      <xsl:value-of select="." />
    </line>
    <line>
      <xsl:text>4950  </xsl:text>
      <xsl:value-of select="concat($MCR.DOI.Resolver.MasterURL, .,'$xR$3Volltext$534')" />
    </line>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='doi']" mode="relatedItem">
    <line>
      <xsl:text>4083  </xsl:text>
      <xsl:value-of select="concat($MCR.DOI.Resolver.MasterURL, .)" />
    </line>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='uri']" mode="pica3">
    <line>
      
      
      <xsl:choose>
        <xsl:when test="@access='preview'">
          <xsl:text>4961  </xsl:text>
          <xsl:value-of select="." />
          <xsl:value-of select="'$3Volltext$534'" />
        </xsl:when>
        <xsl:when test="@access='raw object'">
          <xsl:text>4950  </xsl:text>
          <xsl:value-of select="." />
          <xsl:value-of select="'$3Volltext$534'" />
        </xsl:when>
        <xsl:when test="@access='object in context'">
          <xsl:text>4961  </xsl:text>
          <xsl:value-of select="." />
          <xsl:value-of select="'$3Volltext$534'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>4961  </xsl:text>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </line>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='issn']" mode="relatedItem">
    <line>
      <xsl:text>2010  </xsl:text>
      <xsl:value-of select="." />
    </line>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='urn']" mode="pica3">
    <line>
      <xsl:text>2050  </xsl:text>
      <xsl:value-of select="text()"></xsl:value-of>
    </line>
    <!-- <line>
      <xsl:text>4083  $S1$a</xsl:text>
      <xsl:value-of select="concat($MCR.URN.Resolver.MasterURL, .)" />
      <xsl:text>$qapplication/pdf</xsl:text>
    </line>
    -->
    <line>
      <xsl:text>4950  </xsl:text>
      <xsl:value-of select="concat($MCR.URN.Resolver.MasterURL, .,'$xR$3Volltext$534')" />
    </line>
  </xsl:template>

  <xsl:template match="mods:identifier[@type='zdbid']" mode="relatedItem">
    <line>
      <xsl:text>2110  </xsl:text>
      <xsl:value-of select="." />
    </line>
  </xsl:template>

  <!-- xsl:template match="mods:identifier[@type='intern_old']" mode="pica3">
     <xsl:text>OldInternID  </xsl:text> <xsl:value-of select="." /> <xsl:text>&#10;</xsl:text>
  </xsl:template -->
  <!-- xsl:template match="mods:identifier[@type='citekey']" mode="pica3">
     <xsl:text>Citekey  </xsl:text> <xsl:value-of select="." /> <xsl:text>&#10;</xsl:text>
  </xsl:template -->

  <!--<xsl:template match="mods:relatedItem[@type='host']" mode="pica3">
     <xsl:apply-templates mode="relatedItem" />
  </xsl:template>-->

  <xsl:template match="mods:originInfo/mods:issuance" mode="relatedItem">
  </xsl:template>

  <xsl:template match="mods:originInfo/mods:issuance" mode="relatedItem">
  </xsl:template>

  <xsl:template match="mods:genre" mode="relatedItem">
    <!-- Hier muss geprüft werden ob es wirklich eine Zeitschrift ist oder oben im related Item Template-->
  </xsl:template>

  <!-- <xsl:template match="mods:titleInfo/mods:title" mode="relatedItem">
     <xsl:text>4000  </xsl:text>
     <xsl:value-of select="." />
     <xsl:text>&#10;</xsl:text>
   </xsl:template>-->

  <xsl:template match="mods:recordInfo/mods:recordContentSource[@authority='marcorg']" mode="pica3">
    <line>
      <xsl:text>2240  </xsl:text>
      <xsl:choose>
        <xsl:when test="contains(text(), 'GBV')">
          <xsl:value-of select="concat('GBV: ' , ../mods:recordIdentifier)" />
        </xsl:when>
        <xsl:when test="contains(text(), 'BSZ')">
          <xsl:value-of select="concat('BSZ: ' , ../mods:recordIdentifier)" />
        </xsl:when>
        <xsl:when test="contains(text(), 'BVB')">
          <xsl:value-of select="concat('BVB: ' , ../mods:recordIdentifier)" />
        </xsl:when>
        <xsl:when test="contains(text(), 'DNB')">
          <xsl:value-of select="concat('DNB: ' , ../mods:recordIdentifier)" />
        </xsl:when>
        <xsl:when test="contains(text(), 'HBZ')">
          <xsl:value-of select="concat('HBZ: ' , ../mods:recordIdentifier)" />
        </xsl:when>
        <xsl:when test="contains(text(), 'HEB')">
          <xsl:value-of select="concat('HEB: ' , ../mods:recordIdentifier)" />
        </xsl:when>
        <xsl:when test="contains(text(), 'KBV')">
          <xsl:value-of select="concat('KBV: ' , ../mods:recordIdentifier)" />
        </xsl:when>
        <xsl:when test="contains(text(), 'OBV')">
          <xsl:value-of select="concat('OBV: ' , ../mods:recordIdentifier)" />
        </xsl:when>
        <xsl:when test="contains(text(), 'ZDB')">
          <xsl:value-of select="concat('ZDB: ' , ../mods:recordIdentifier)" />
        </xsl:when>
      </xsl:choose>
    </line>
  </xsl:template>

  <!-- <xsl:template match="mods:originInfo" mode="relatedItem">
     <xsl:text>4030  </xsl:text>
     <xsl:choose>
       <xsl:when test="mods:place/mods:placeTerm">
         <xsl:value-of select="mods:place/mods:placeTerm" />
         <xsl:text>,</xsl:text>
       </xsl:when>
       <xsl:otherwise>
         <xsl:text>o.A.</xsl:text>
       </xsl:otherwise>
     </xsl:choose>
     <xsl:value-of select="mods:publisher" />
     <xsl:text>&#10;</xsl:text>
   </xsl:template>-->

  <xsl:template match="mods:originInfo/mods:publisher" mode="pica3">
    <line>
      <xsl:text>4030  </xsl:text>
      <xsl:value-of select="concat(../mods:place/mods:placeTerm[@type='text'], '$n', text())" />
    </line>
  </xsl:template>

  <xsl:template match="mods:originInfo[not(mods:publisher)]/mods:place/mods:placeTerm[@type='text']">
    <line>
      <xsl:text>4030  </xsl:text>
      <xsl:value-of select="text()" />
    </line>
  </xsl:template>

  <!--<xsl:template match="mods:accessCondition[contains(@xlink:href, 'rights_reserved')]">
    <xsl:text>4239  </xsl:text>
    <xsl:value-of select="@type" />
    <xsl:text>&#10;</xsl:text>
  </xsl:template> --><!--Frage welche AccessCondition wichtig-->

  <xsl:template match="mods:part" mode="relatedItem">
    <line>
      <xsl:text>4070   </xsl:text>
      <!--<xsl:apply-templates mode="relatedItem" />-->
    </line>
  </xsl:template>

  <xsl:template match="mods:detail[@type='issue']" mode="relatedItem">
    <xsl:text>/a</xsl:text>
    <xsl:value-of select="mods:number" />
  </xsl:template>

  <xsl:template match="mods:detail[@type='volume']" mode="relatedItem">
    <xsl:text>/v</xsl:text>
    <xsl:value-of select="mods:number" />
  </xsl:template>

  <xsl:template match="mods:extent[@unit='pages']" mode="relatedItem">
    <xsl:text>/p</xsl:text>
    <xsl:value-of select="mods:start" />
    <xsl:text>-</xsl:text>
    <xsl:value-of select="mods:end" />
  </xsl:template>

  <xsl:template match="mods:date" mode="relatedItem">
    <xsl:text>/j</xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="mods:dateIssued" mode="relatedItem">
  </xsl:template>

  <xsl:template match="mods:genre[@authority='marcgt']" mode="pica3">
  </xsl:template>

  <!-- ========== ignore the rest ========== -->
  <xsl:template match="node()|@*">
    <!-- xsl:message terminate="no">
     WARNING: Unmatched element: <xsl:value-of select="name()"/>
    </xsl:message -->
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="node()|@*" mode="pica3">
    <!-- xsl:message terminate="no">
      WARNING: Unmatched pica3 element: <xsl:value-of select="name()"/>
     </xsl:message -->
    <xsl:apply-templates mode="pica3" />
  </xsl:template>

  <xsl:template match="mods:relatedItem" mode="pica3">
    <xsl:apply-templates select="mods:part"/>
  </xsl:template>

  <xsl:template match="node()|@*" mode="relatedItem">
    <!-- xsl:message terminate="no">
      WARNING: Unmatched relatedItem element: <xsl:value-of select="name()"/>
    </xsl:message -->
    <!--<xsl:apply-templates mode="relatedItem" />-->
  </xsl:template>

</xsl:stylesheet>
