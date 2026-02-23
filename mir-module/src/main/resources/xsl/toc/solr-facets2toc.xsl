<?xml version="1.0" encoding="UTF-8"?>

<!--
  Transforms solr response from the solr facet query to a simpler xml to display a table of contents.

  <toc layout="journal">
    <level field="mir.toc.host.volume" expanded="true">
      <item value="2019">
        <level field="mir.toc.host.issue" expanded="false">
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

<xsl:stylesheet version="1.0"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xalan">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" xalan:indent-amount="2" />

  <xsl:param name="tocLayoutID" />

  <xsl:template match="/response">
    <!-- the ID of the toc layout was transported from solr back to here as custom request param: -->
    <toc layout="{$tocLayoutID}">
      <xsl:apply-templates select="lst[@name='facets']/lst" />
    </toc>
  </xsl:template>

  <xsl:template match="lst[descendant::lst[@name='docs'][arr/lst]]">

    <xsl:variable name="field" select="@name" />
    <xsl:variable name="params" select="/response/lst[@name='responseHeader']/lst[@name='params']"/>
    <xsl:variable name="expanded" select="$params/str[@name=concat('toc.',$field,'.expanded')]"/>
    <xsl:variable name="displayField" select="$params/str[@name=concat('toc.',$field,'.displayField')]" />

    <!-- find the field name whose presence identifies the single document that "represents" this toc level as object -->
    <xsl:variable name="levelField">
      <xsl:choose>
        <xsl:when test="starts-with($field,'mir.toc.host.')">
          <xsl:value-of select="concat($field,'.top')" />
        </xsl:when>
        <xsl:when test="starts-with($field,'mir.toc.series.')">
          <xsl:value-of select="concat($field,'.top')" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <!-- represents a single level in toc -->
    <level field="{$field}" expanded="{$expanded}"> <!-- show expanded=true|false when level is displayed -->
      <xsl:attribute name="expanded">
        <xsl:choose>
          <xsl:when test="($expanded='first') and preceding::lst[@name=current()/@name]">
            <xsl:text>false</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$expanded" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:for-each select="arr/lst">
        <xsl:variable name="value" >
          <xsl:choose>
            <xsl:when test="$displayField">
              <!--
                  1. all documents in this bucket must have the same value for the $field, because that
                     field (level/@field) is used to create the bucket
                  2. the display field (level/@displayField) of a level, ip present, must be selected
                     such, that all documents with the same field value also have the same display field value
                  3. therefore: all documents in this bucket must have the same value for the
                     display field (level/@displayField)
                  4. therefore: it is safe to pick any document in this bucket to look up either the field
                     or display field value. we use the first document
                  5. the fist document might be nested multiple levels deep if there are levels
                     without publications
              -->
              <xsl:variable name="firstId" select="(descendant::lst[@name='docs']/arr/lst/str[@name='val'])[1]"/>
              <xsl:value-of select="key('id2doc',$firstId)/*[@name=$displayField]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="*[@name='val']"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <item value="{$value}">

          <!-- there may be a single document that "represents" this toc level as object -->
          <!-- for example, there may be an object for the complete current issue -->
          <xsl:for-each select="lst[@name='docs']/arr/lst">
            <xsl:apply-templates select="key('id2doc',str[@name='val'])[str[@name=$levelField]]" />
          </xsl:for-each>

          <!-- handle deeper levels and publication list -->
          <xsl:apply-templates select="lst">
            <xsl:with-param name="levelField" select="$levelField" />
          </xsl:apply-templates>

        </item>
      </xsl:for-each>
    </level>
  </xsl:template>

  <xsl:key name="id2doc" match="/response/result/doc" use="str[@name='id']" />

  <!-- output list of publications at the current toc level, if any -->
  <xsl:template match="lst[@name='docs']">
    <xsl:param name="levelField" select="'?'" />

    <xsl:variable name="publications">
      <xsl:for-each select="arr/lst">
        <!-- skip publication document if it is not below, but -at- the current level, e.g. level=issue, category.top=mir_genres:issue -->
        <xsl:apply-templates select="key('id2doc',str[@name='val'])[not(str[@name=$levelField])]" />
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