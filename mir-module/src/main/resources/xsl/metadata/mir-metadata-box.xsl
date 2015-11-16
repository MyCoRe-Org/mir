<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="i18n mods xlink">
  <xsl:import href="xslImport:modsmeta:metadata/mir-metadata-box.xsl" />
  <xsl:include href="modsmetadata.xsl" />
  <!-- copied from http://www.loc.gov/standards/mods/v3/MODS3-4_HTML_XSLT1-0.xsl -->

  <xsl:key use="@type" name="title-by-type" match="//mods:mods/mods:titleInfo" />

  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <!-- $mods-type contains genre -->
    <div id="mir-metadata">
      <xsl:apply-templates />
      <!--
      <dl>
        <dt>metaname</dt>
        <dd>metavalue</dd>
      </dl>
       -->
        <table class="mir-metadata">

            <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[@type and
                                  count(. | key('title-by-type',@type)[1])=1]">
              <tr>
                <td valign="top" class="metaname">
                  <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.title')" />
                  <xsl:text> (</xsl:text>
                  <xsl:value-of select="i18n:translate(concat('mir.title.type.', @type))" />
                  <xsl:if test="@type='translated'">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="@xml:lang" />
                  </xsl:if>
                  <xsl:text>):</xsl:text>
                </td>
                <td class="metavalue">
                  <xsl:for-each select="key('title-by-type',@type)">
                    <xsl:if test="position()!=1">
                      <br />
                    </xsl:if>
                    <xsl:apply-templates select="//mods:mods" mode="mods.title">
                      <xsl:with-param name="type" select="@type" />
                      <xsl:with-param name="withSubtitle" select="true()" />
                      <xsl:with-param name="position" select="position()" />
                    </xsl:apply-templates>
                  </xsl:for-each>
                </td>
              </tr>
            </xsl:for-each>

            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[@type='conference']/mods:namePart[not(@type)]" />
              <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.conference.title')" />
            </xsl:call-template>


            <!-- mods:name grouped by mods:role/mods:roleTerm excluding author-->
            <xsl:for-each
              select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[not(@ID) and
                      @type='personal' and not(mods:role/mods:roleTerm='aut') and
                      count(. | key('name-by-role',mods:role/mods:roleTerm)[1])=1]">
              <!-- for every role -->
              <xsl:choose>
                <!-- check if 'aut' and 'edt' show 'edt', otherwise 'edt' is already shown in abstract-box -->
                <xsl:when test="mods:role/mods:roleTerm='edt' and not(../mods:role/mods:roleTerm='aut')">
                  <!-- do nothing -->
                </xsl:when>
                <xsl:otherwise>
                  <tr>
                    <td valign="top" class="metaname">
                      <xsl:choose>
                        <xsl:when test="mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']">
                          <xsl:apply-templates select="mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']"
                            mode="printModsClassInfo" />
                          <xsl:value-of select="':'" />
                        </xsl:when>
                        <xsl:when test="mods:role/mods:roleTerm[@authority='marcrelator']">
                          <xsl:value-of
                            select="concat(i18n:translate(concat('component.mods.metaData.dictionary.',mods:role/mods:roleTerm[@authority='marcrelator'])),':')" />
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.name'),':')" />
                        </xsl:otherwise>
                      </xsl:choose>
                    </td>
                    <td class="metavalue">
                      <xsl:for-each select="key('name-by-role',mods:role/mods:roleTerm)">
                        <xsl:if test="position()!=1">
                          <xsl:value-of select="'; '" />
                        </xsl:if>
                        <xsl:apply-templates select="." mode="nameLink" />
                      </xsl:for-each>
                        <xsl:if test="$mods/mods:name/mods:etal">
                            <em>et.al.</em>
                        </xsl:if>
                    </td>
                  </tr>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>

            <xsl:for-each select="mycoreobject">
              <xsl:if test="./structure/parents/parent/@xlink:href">
                <xsl:call-template name="printMetaDate.mods.relatedItem">
                  <xsl:with-param name="parentID" select="./structure/parents/parent/@xlink:href" />
                  <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.confpubIn')" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='series']/@xlink:href">
                <xsl:call-template name="printMetaDate.mods.relatedItem">
                  <xsl:with-param name="parentID" select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='series']/@xlink:href" />
                  <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.articleIn')" />
                </xsl:call-template>
              </xsl:if>
              <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='series' and not(@xlink:href)]">
                <xsl:call-template name="printMetaDate.mods">
                  <xsl:with-param name="nodes" select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='series' and not(@xlink:href)]/mods:titleInfo/mods:title" />
                  <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.articleIn')" />
                </xsl:call-template>
              </xsl:if>
            </xsl:for-each>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:edition" />
            </xsl:call-template>
            <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type!='open-aire' and @type!='intern']" />
            <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='issn']">
              <xsl:variable name="sherpa_issn" select="." />
              <xsl:for-each select="document(concat('http://www.sherpa.ac.uk/romeo/api29.php?ak=', $MCR.Mods.SherpaRomeo.ApiKey, '&amp;issn=', $sherpa_issn))//publishers/publisher">
                <tr>
                  <td class="metaname" valign="top">SHERPA/RoMEO:</td>
                  <td class="metavalue">
                    <a href="http://www.sherpa.ac.uk/romeo/search.php?issn={$sherpa_issn}">RoMEO <xsl:value-of select="romeocolour" /> Journal</a>
                  </td>
                </tr>
              </xsl:for-each>
            </xsl:for-each>
            <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:language" />
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes"
                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:physicalDescription/mods:extent" />
            </xsl:call-template>
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:dateCreated"
              mode="present" />
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:dateOther[@type='submitted']"
              mode="present">
              <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.dateSubmitted')" />
            </xsl:apply-templates>
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:dateOther[@type='accepted']"
              mode="present">
              <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.dateAccepted')" />
            </xsl:apply-templates>
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='review']/mods:dateOther[@type='reviewed']"
              mode="present">
                <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.dateReviewed')" />
            </xsl:apply-templates>
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:dateCaptured"
              mode="present" />
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:dateIssued"
              mode="present" />
            <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:dateModified"
              mode="present" />
            <xsl:apply-templates mode="openaire" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='open-aire']" />
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes"
                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[not(@authority='marccountry')]" />
            </xsl:call-template>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes"
                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:place/mods:placeTerm[not(@authority='marccountry')]" />
              <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.placeTerm.creation')" />
            </xsl:call-template>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
            </xsl:call-template>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:publisher" />
              <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.publisher.creation')" />
            </xsl:call-template>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:subject" />
              <xsl:with-param name="sep" select="'; '" />
              <xsl:with-param name="property" select="'keyword'" />
            </xsl:call-template>
            <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[@displayLabel!='status' or not(attribute::displayLabel)]" />
            <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:part/mods:extent" />
            <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:location/mods:url" />
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:location/mods:physicalLocation" />
            </xsl:call-template>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:location/mods:shelfLocator" />
              <xsl:with-param name="label" select="i18n:translate('mir.shelfmark')" />
            </xsl:call-template>
            <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[@type='corporate']" />
          </table>

    </div>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>