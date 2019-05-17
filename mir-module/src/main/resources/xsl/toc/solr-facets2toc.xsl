<?xml version="1.0" encoding="UTF-8"?>

<!-- 
  Transforms solr response from the solr facet query to a simpler xml to display a table of contents.
  
  <toc layout="journal">
    <level field="host.volume" expanded="true">
      <item value="2019">
        <level field="host.issue" expanded="false">
          <item value="24">
            <publications>
              <doc id="mir_mods_1234">
                ...
              </doc>
              <doc id="..."> 
              ...
          </item>
        </level>
      </item>
      <item value="2018">
        ...   
      </item>
    </level>
  </toc> 
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:template match="/response">
    <!-- the ID of the toc layout was transported from solr back to here as custom request param: -->
    <toc layout="{lst[@name='responseHeader']/lst[@name='params']/str[@name='tocLayout']}">
      <xsl:apply-templates select="lst[@name='facets']/lst" />
    </toc>
  </xsl:template>
  
  <xsl:template match="lst[descendant::lst[@name='docs'][arr/lst]]">
    <!-- the default expanded/collapsed state of this toc level was encoded into the facet field name: -->
    <!-- e.g. volume_expanded_true, issue_expanded_false -->
    <xsl:variable name="field" select="substring-before(@name,'_expanded_')" />
    <xsl:variable name="expanded" select="substring-after(@name,'_expanded_')" />
  
    <!--  build the mir_genres publication type ID, e.g. host.issue = mir_genres:issue -->
    <xsl:variable name="category.top">
      <xsl:choose>
        <xsl:when test="starts-with($field,'host.')">
          <xsl:value-of select="concat('mir_genres:',substring-after($field,'host.'))" />
        </xsl:when>
        <xsl:when test="starts-with($field,'series.')">
          <xsl:value-of select="concat('mir_genres:',substring-after($field,'series.'))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('mir_genres:',$field)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- represents a single level in toc -->
    <level field="{$field}" expanded="{$expanded}"> <!-- show expanded=true|false when level is displayed -->
      <xsl:for-each select="arr/lst">
        <item value="{*[@name='val']}">
        
          <!-- there may be a single document that "represents" this toc level as object -->
          <!-- for example, there may be an object for the complete current issue -->
          <xsl:for-each select="lst[@name='docs']/arr/lst">
            <xsl:apply-templates select="key('id2doc',str[@name='val'])[arr[@name='category.top'][str[text()=$category.top]]]" />
          </xsl:for-each>
        
          <!-- handle deeper levels and publication list -->
          <xsl:apply-templates select="lst">
            <xsl:with-param name="category.top" select="$category.top" />
          </xsl:apply-templates>
 
        </item>
      </xsl:for-each>
    </level>
  </xsl:template>
  
  <xsl:key name="id2doc" match="/response/result/doc" use="str[@name='id']" />

  <!-- output list of publications at the current toc level, if any -->
  <xsl:template match="lst[@name='docs']">
    <xsl:param name="category.top" select="'?'" />
    
    <xsl:variable name="publications">
      <xsl:for-each select="arr/lst">
        <!-- skip publication document if it is not below, but -at- the current level, e.g. level=issue, category.top=mir_genres:issue -->
        <xsl:apply-templates select="key('id2doc',str[@name='val'])[not(arr[@name='category.top'][str[text()=$category.top]])]" />
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="string-length($publications) &gt; 0">
      <publications>
        <xsl:copy-of select="$publications" />
      </publications>
    </xsl:if>
  </xsl:template>

  <!-- a single publication within toc, preserve sort order as pos attribute for later sorting -->
  <xsl:template match="doc">
    <doc id="{str[@name='id']}" pos="{count(preceding-sibling::doc)+1}">
      <xsl:apply-templates select="*" />
    </doc>
  </xsl:template>
  
  <!-- simplify arrays in solr response by just repeating the field -->
  <xsl:template match="doc/arr" priority="1">
    <xsl:for-each select="*">
      <field name="{../@name}">
        <xsl:value-of select="text()" />
      </field>
    </xsl:for-each>
  </xsl:template>

  <!-- simplify solr response, transform each str|int and so on to just a "field" -->
  <xsl:template match="doc/*">
    <field name="{@name}">
      <xsl:value-of select="text()" />
    </field>
  </xsl:template>

</xsl:stylesheet>