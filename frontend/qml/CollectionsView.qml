import QtQuick 2.3
import QtQuick.Controls 1.2
import "Components"
import vg.phoenix.models 1.0
import vg.phoenix.themes 1.0

ScrollView {
    width: 100
    height: 62
    ListView {
        id: listView;
        model:  CollectionsModel { id: collectionsModel; }
        header: CollectionsHeader{}
        delegate:IconTile{ }
    }

}

