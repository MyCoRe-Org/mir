<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xalan i18n">

  <xsl:include href="mycoreclass-versioned-labels.xsl" />
  
  <xsl:key name="categories" match="category" use="@ID" />

  <!-- For non-unique (that means versioned) categories, add a version suffix to @ID -->  
  <xsl:template match="category/@ID[count(key('categories',.)) &gt; 1]">
    <xsl:attribute name="ID">
      <xsl:value-of select="." />
      
      <xsl:choose>
        <xsl:when test="ancestor::valid[@from]">
          <xsl:call-template name="addVersionNumber">
            <xsl:with-param name="fromUntil" select="'from'" />
          </xsl:call-template>
        </xsl:when> 
        <xsl:when test="ancestor::valid[@until]">
          <xsl:call-template name="addVersionNumber">
            <xsl:with-param name="fromUntil" select="'until'" />
          </xsl:call-template>
        </xsl:when> 
      </xsl:choose>
      
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template name="addVersionNumber">
    <xsl:param name="fromUntil" />
    
    <xsl:variable name="date" select="translate(ancestor::valid[@*[name()=$fromUntil]][1]/@*[name()=$fromUntil],'-','')" />

    <xsl:variable name="id" select="." />
    
    <xsl:variable name="numEarlierFrom" select="count(key('categories',$id)[translate(ancestor::valid[@from][1]/@from,'-','') &lt; $date])" />
    <xsl:variable name="numEarlierUntil" select="count(key('categories',$id)[translate(ancestor::valid[@until][1]/@until,'-','') &lt; $date])" />
    
    <xsl:variable name="numEarlier" select="$numEarlierFrom + $numEarlierUntil" />

    <!-- omit version suffix for the first (earliest) version/date -->
    <xsl:if test="$numEarlier &gt; 0">          
      <xsl:value-of select="concat('_v',substring($date,3))" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
